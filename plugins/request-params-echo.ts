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

function parseMaybeJSON(value: unknown): any | null {
  if (typeof value !== 'string' || !value.trim()) return null;
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}

function toHttpStatus(value: unknown): number | null {
  const n = Number(value);
  if (Number.isInteger(n) && n >= 100 && n <= 599) return n;
  return null;
}

function extractStatusCode(event: any): number | null {
  const err = (event && event.properties && event.properties.error) || event?.error || {};
  const rootBody =
    event?.responseBody && typeof event.responseBody === 'string'
      ? parseMaybeJSON(event.responseBody)
      : event?.responseBody;
  const errBody =
    err?.data?.responseBody && typeof err.data.responseBody === 'string'
      ? parseMaybeJSON(err.data.responseBody)
      : err?.data?.responseBody;

  const candidates = [
    event?.properties?.httpStatus,
    event?.properties?.statusCode,
    event?.properties?.status,
    event?.httpStatus,
    event?.statusCode,
    event?.status,
    err?.data?.statusCode,
    err?.statusCode,
    err?.status,
    rootBody?.statusCode,
    rootBody?.status,
    errBody?.statusCode,
    errBody?.status,
  ];
  for (const c of candidates) {
    const n = toHttpStatus(c);
    if (n !== null) return n;
  }
  return null;
}

function extractErrorMessage(event: any): string | undefined {
  const err = (event && event.properties && event.properties.error) || event?.error || {};
  const rootBody =
    event?.responseBody && typeof event.responseBody === 'string'
      ? parseMaybeJSON(event.responseBody)
      : event?.responseBody;
  const errBody =
    err?.data?.responseBody && typeof err.data.responseBody === 'string'
      ? parseMaybeJSON(err.data.responseBody)
      : err?.data?.responseBody;

  const candidates = [
    event?.properties?.error?.message,
    event?.error?.message,
    err?.message,
    err?.data?.message,
    errBody?.error?.message,
    errBody?.message,
    rootBody?.error?.message,
    rootBody?.message,
  ];

  for (const c of candidates) {
    if (typeof c === 'string' && c.trim()) return c.trim();
  }
  return undefined;
}

type CapturedStatus = {
  httpStatus: number;
  errorMessage?: string;
};

export const RequestParamsEchoPlugin: Plugin = async ({ client }) => {
  writeDebug('[init] RequestParamsEchoPlugin loaded');

  const injectedMessageIDs = new Set<string>();
  const lastStatusBySession = new Map<string, CapturedStatus>();

  return {
    config: async () => {
      writeDebug('[config] config hook executed');
    },

    event: async ({ event }: { event: any }) => {
      if (!event) return;
      const code = extractStatusCode(event);
      if (code === null) return;
      const errorMessage = extractErrorMessage(event);

      const sessionID = event?.properties?.sessionID || event?.sessionID || '';
      if (sessionID) {
        lastStatusBySession.set(sessionID, { httpStatus: code, errorMessage });
      }
      writeDebug(
        `[event] status captured type=${event?.type || 'n/a'} session=${sessionID || 'n/a'} http_status=${String(code)} has_error_message=${String(Boolean(errorMessage))}`
      );
    },

    'chat.message': async (input: any) => {
      const sessionID = input?.sessionID || '';
      if (!sessionID) return;
      writeDebug(
        `[chat.message] request started session=${sessionID} provider=${input?.model?.providerID || 'n/a'} model=${input?.model?.modelID || 'n/a'}`
      );
    },

    // Force-disable SDK retries before sending the model request.
    'chat.params': async (input: any, output: any) => {
      output.options = output.options || {};
      output.options.maxRetries = 0;
      output.options.maxRetry = 0;
      output.options.retries = 0;
      writeDebug(
        `[chat.params] forced maxRetries=0/maxRetry=0/retries=0 session=${input?.sessionID || 'n/a'} provider=${input?.provider?.info?.id || 'n/a'} model=${input?.model?.id || input?.model?.name || 'n/a'}`
      );
    },

    // Only override output for real HTTP 400 with server error.message.
    'experimental.text.complete': async (input: any, output: any) => {
      const sessionID = input && input.sessionID ? input.sessionID : '';
      const messageID = input && input.messageID ? input.messageID : '';
      if (!sessionID || !messageID) return;
      if (injectedMessageIDs.has(messageID)) return;

      const currentText = typeof output.text === 'string' ? output.text : '';
      if (!currentText.trim()) return;

      const captured = lastStatusBySession.get(sessionID);
      if (captured === undefined) return;

      const has400ErrorMessage =
        captured.httpStatus === 400 &&
        typeof captured.errorMessage === 'string' &&
        captured.errorMessage.trim().length > 0;

      if (has400ErrorMessage) {
        output.text = captured.errorMessage;
      }
      injectedMessageIDs.add(messageID);
      lastStatusBySession.delete(sessionID);

      writeDebug(
        `[text.complete] injected session=${sessionID} message=${messageID} http_status=${String(captured.httpStatus)} replace_with_400_message=${String(has400ErrorMessage)}`
      );
      try {
        await client.app.log({
          body: {
            service: 'request-params-echo-plugin',
            level: 'info',
            message: 'experimental.text.complete injected',
            extra: {
              sessionID,
              messageID,
              http_status: captured.httpStatus,
              replace_with_400_message: has400ErrorMessage,
            },
          },
        });
      } catch {}
    },
  };
};

export default RequestParamsEchoPlugin;
