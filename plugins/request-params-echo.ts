import fs from 'fs';
import path from 'path';
import type { Plugin } from '@opencode-ai/plugin';

const DEBUG_FILE = path.join(process.cwd(), '.opencode', 'plugin-debug.log');

function ensureDebugDir(): void {
  try {
    fs.mkdirSync(path.dirname(DEBUG_FILE), { recursive: true });
  } catch {}
}

function writeDebug(line: string): void {
  try {
    ensureDebugDir();
    fs.appendFileSync(DEBUG_FILE, `${new Date().toISOString()} ${line}\n`, 'utf8');
  } catch {}
}

function extractTextFromParts(parts: any[]): string {
  if (!Array.isArray(parts)) return '';
  return parts
    .filter((p) => p && p.type === 'text' && typeof p.text === 'string')
    .map((p) => p.text)
    .join('\n')
    .trim();
}

function buildParamLine(text: any): string {
  const payload = { network_status: text };
  return `[PLUGIN_ACTIVE][NETWORK_STATUS] ${JSON.stringify(payload)}`;
}

function parseMaybeJSON(value: unknown): any | null {
  if (typeof value !== 'string' || !value.trim()) return null;
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}

function extractStatusCode(event: any): number | null {
  const err = (event && event.properties && event.properties.error) || event.error || {};
  const body =
    err && err.data && typeof err.data.responseBody === 'string'
      ? parseMaybeJSON(err.data.responseBody)
      : err && err.data && err.data.responseBody;
  const candidates = [
    err?.data?.statusCode,
    err?.statusCode,
    err?.status,
    err?.code,
    body?.statusCode,
    body?.status,
    body?.code,
    body?.errorcode,
  ];
  for (const c of candidates) {
    const n = Number(c);
    if (Number.isFinite(n)) return n;
  }
  return null;
}

function extractErrorMsg(event: any): string {
  const err = (event && event.properties && event.properties.error) || event.error || {};
  const body =
    err && err.data && typeof err.data.responseBody === 'string'
      ? parseMaybeJSON(err.data.responseBody)
      : err && err.data && err.data.responseBody;
  return (
    body?.msg ||
    body?.message ||
    body?.error?.msg ||
    body?.error?.message ||
    err?.data?.message ||
    err?.message ||
    'request_failed'
  );
}

type SessionRequestState = {
  startedAt: number;
  providerID?: string;
  modelID?: string;
};

export const RequestParamsEchoPlugin: Plugin = async ({ client }) => {
  writeDebug('[init] RequestParamsEchoPlugin loaded');

  const injectedMessageIDs = new Set();
  const requestBySession = new Map<string, SessionRequestState>();
  const lastStatusBySession = new Map<string, any>();

  return {
    config: async () => {
      writeDebug('[config] config hook executed');
    },

    event: async ({ event }: { event: any }) => {
      if (!event || event.type !== 'session.error') return;
      const code = extractStatusCode(event);
      const message = extractErrorMsg(event);
      const sessionID = event?.properties?.sessionID || '';
      const req = sessionID ? requestBySession.get(sessionID) : undefined;
      const latencyMs = req ? Date.now() - req.startedAt : undefined;

      const status = {
        status: 'error',
        code: code ?? 'unknown',
        message,
        latency_ms: latencyMs,
        provider_id: req?.providerID,
        model_id: req?.modelID,
      };

      if (sessionID) {
        lastStatusBySession.set(sessionID, status);
        requestBySession.delete(sessionID);
      }
      writeDebug(
        `[event] session.error captured session=${sessionID || 'n/a'} code=${String(status.code)} msg=${message}`
      );
    },

    'chat.message': async (input: any) => {
      const sessionID = input?.sessionID || '';
      if (!sessionID) return;
      requestBySession.set(sessionID, {
        startedAt: Date.now(),
        providerID: input?.model?.providerID,
        modelID: input?.model?.modelID,
      });
      writeDebug(
        `[chat.message] request started session=${sessionID} provider=${input?.model?.providerID || 'n/a'} model=${input?.model?.modelID || 'n/a'}`
      );
    },

    // Prepend real network status for this request to assistant text.
    'experimental.text.complete': async (input: any, output: any) => {
      const sessionID = input && input.sessionID ? input.sessionID : '';
      const messageID = input && input.messageID ? input.messageID : '';
      if (!sessionID || !messageID) return;
      if (injectedMessageIDs.has(messageID)) return;

      const currentText = typeof output.text === 'string' ? output.text : '';
      if (!currentText.trim()) return;
      if (currentText.includes('[PLUGIN_ACTIVE][NETWORK_STATUS]')) return;

      const req = requestBySession.get(sessionID);
      const fallback = lastStatusBySession.get(sessionID);
      const realStatus =
        fallback ||
        {
          status: 'success',
          code: 200,
          message: 'ok',
          latency_ms: req ? Date.now() - req.startedAt : undefined,
          provider_id: req?.providerID,
          model_id: req?.modelID,
        };

      const paramLine = buildParamLine(realStatus);
      output.text = `${paramLine}\n${currentText}`.trim();
      injectedMessageIDs.add(messageID);
      requestBySession.delete(sessionID);
      lastStatusBySession.delete(sessionID);

      writeDebug(
        `[text.complete] injected network status session=${sessionID} message=${messageID} status=${realStatus.status} code=${String(realStatus.code)}`
      );
      try {
        await client.app.log({
          body: {
            service: 'request-params-echo-plugin',
            level: 'info',
            message: 'experimental.text.complete injected',
            extra: { sessionID, messageID, status: realStatus },
          },
        });
      } catch {}
    },
  };
};

export default RequestParamsEchoPlugin;
