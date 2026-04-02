import fs from 'fs';
import os from 'os';
import path from 'path';

type SessionState = {
  lastUpdated: string;
  activeNamespace: 'speckit' | 'openspec' | 'superpowers' | 'unknown';
  activeCommand: string;
  activeChange: string;
};

const DEFAULT_STATE: SessionState = {
  lastUpdated: '',
  activeNamespace: 'unknown',
  activeCommand: '',
  activeChange: '',
};

function normalizePath(input: unknown): string | null {
  if (typeof input !== 'string') return null;
  const trimmed = input.trim();
  if (!trimmed) return null;
  if (trimmed === '~') return os.homedir();
  if (trimmed.startsWith('~/')) return path.join(os.homedir(), trimmed.slice(2));
  return path.resolve(trimmed);
}

function ensureDir(p: string): void {
  try {
    fs.mkdirSync(p, { recursive: true });
  } catch {
    // best-effort only
  }
}

function readState(stateFile: string): SessionState {
  try {
    if (!fs.existsSync(stateFile)) return { ...DEFAULT_STATE };
    const parsed = JSON.parse(fs.readFileSync(stateFile, 'utf8')) as SessionState;
    return {
      ...DEFAULT_STATE,
      ...parsed,
    };
  } catch {
    return { ...DEFAULT_STATE };
  }
}

function writeState(stateFile: string, state: SessionState): void {
  try {
    fs.writeFileSync(stateFile, JSON.stringify(state, null, 2), 'utf8');
  } catch {
    // best-effort only
  }
}

function getLatestUserMessage(messages: any[]): any | null {
  for (let i = messages.length - 1; i >= 0; i -= 1) {
    const m = messages[i];
    if (m?.info?.role === 'user') return m;
  }
  return null;
}

function extractTextParts(message: any): string {
  const parts = Array.isArray(message?.parts) ? message.parts : [];
  return parts
    .filter((p: any) => p?.type === 'text' && typeof p.text === 'string')
    .map((p: any) => p.text)
    .join('\n');
}

function parseSessionHints(text: string): Partial<SessionState> {
  const trimmed = text.trim();

  const commandMatch = trimmed.match(/\/(speckit|openspec|superpowers)-([a-z-]+)/i);
  const namespaceRaw = commandMatch?.[1]?.toLowerCase();
  const fullCommand = commandMatch ? `/${commandMatch[1].toLowerCase()}-${commandMatch[2].toLowerCase()}` : '';

  const namespace: SessionState['activeNamespace'] =
    namespaceRaw === 'speckit' || namespaceRaw === 'openspec' || namespaceRaw === 'superpowers'
      ? (namespaceRaw as SessionState['activeNamespace'])
      : 'unknown';

  // Heuristic change capture: first token after command if it looks like a slug.
  let activeChange = '';
  if (commandMatch) {
    const after = trimmed.slice(trimmed.indexOf(commandMatch[0]) + commandMatch[0].length).trim();
    const token = after.split(/\s+/)[0] || '';
    if (/^[a-z0-9][a-z0-9-]{1,80}$/.test(token)) activeChange = token;
  }

  return {
    activeNamespace: namespace,
    activeCommand: fullCommand,
    activeChange,
    lastUpdated: new Date().toISOString(),
  };
}

function injectStateSummary(output: any, state: SessionState): void {
  if (!output?.messages?.length) return;
  const firstUser = output.messages.find((m: any) => m?.info?.role === 'user');
  if (!firstUser || !Array.isArray(firstUser.parts) || firstUser.parts.length === 0) return;

  const alreadyInjected = firstUser.parts.some(
    (p: any) => p?.type === 'text' && typeof p.text === 'string' && p.text.includes('<SESSION_STATE>')
  );
  if (alreadyInjected) return;

  const summary = [
    '<SESSION_STATE>',
    `activeNamespace: ${state.activeNamespace}`,
    `activeCommand: ${state.activeCommand || 'n/a'}`,
    `activeChange: ${state.activeChange || 'n/a'}`,
    `lastUpdated: ${state.lastUpdated || 'n/a'}`,
    '</SESSION_STATE>',
  ].join('\n');

  const ref = firstUser.parts[0];
  firstUser.parts.unshift({ ...ref, type: 'text', text: summary });
}

export const SessionStatePlugin = async () => {
  const configDir =
    normalizePath(process.env.OPENCODE_CONFIG_DIR) || path.join(os.homedir(), '.config', 'opencode');
  const stateDir = path.join(configDir, '.state');
  const stateFile = path.join(stateDir, 'session-state.json');

  ensureDir(stateDir);

  return {
    config: async (config: any) => {
      config.session = config.session || {};
      config.session.stateFile = config.session.stateFile || stateFile;
    },

    'experimental.chat.messages.transform': async (_input: any, output: any) => {
      const current = readState(stateFile);
      const latestUser = getLatestUserMessage(output?.messages || []);
      const latestText = extractTextParts(latestUser);
      const hints = parseSessionHints(latestText);

      const merged: SessionState = {
        ...current,
        ...hints,
        activeChange: hints.activeChange || current.activeChange,
      };

      writeState(stateFile, merged);
      injectStateSummary(output, merged);
    },
  };
};

export default SessionStatePlugin;
