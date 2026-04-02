import fs from 'fs';
import os from 'os';
import path from 'path';

function normalizePath(input: unknown): string | null {
  if (typeof input !== 'string') return null;
  const trimmed = input.trim();
  if (!trimmed) return null;
  if (trimmed === '~') return os.homedir();
  if (trimmed.startsWith('~/')) return path.join(os.homedir(), trimmed.slice(2));
  return path.resolve(trimmed);
}

function readPolicyFile(policyPath: string): string {
  try {
    if (!fs.existsSync(policyPath)) return '';
    return fs.readFileSync(policyPath, 'utf8').trim();
  } catch {
    return '';
  }
}

function extractLatestUserText(messages: any[]): string {
  for (let i = messages.length - 1; i >= 0; i -= 1) {
    const m = messages[i];
    if (m?.info?.role !== 'user') continue;
    const parts = Array.isArray(m.parts) ? m.parts : [];
    const texts = parts
      .filter((p) => p?.type === 'text' && typeof p.text === 'string')
      .map((p) => p.text);
    if (texts.length) return texts.join('\n');
  }
  return '';
}

function buildPolicyBlock(policyContent: string, latestUserText: string): string {
  const completionSignal = /\b(done|complete|finished|ship|ready)\b/i.test(latestUserText);
  const verifySignal = /\b(test|verify|build|lint|check)\b/i.test(latestUserText);

  const base = [
    '<POLICY_BLOCK>',
    'You are operating under company policy constraints.',
    'Hard requirements:',
    '1. Use only configured local command namespaces and local skills.',
    '2. Do not require installing third-party packages to run workflows.',
    '3. Before any completion claim, require fresh verification evidence from this session.',
    '4. If blocked by ambiguity or missing prerequisites, stop and ask for clarification.',
    '5. Prefer deterministic, auditable actions over implicit assumptions.',
  ];

  if (policyContent) {
    base.push('--- Company Policy File ---');
    base.push(policyContent);
    base.push('--- End Company Policy File ---');
  }

  if (completionSignal && !verifySignal) {
    base.push('Policy reminder: completion-like language detected without explicit verification intent. Ask for or run verification first.');
  }

  base.push('</POLICY_BLOCK>');
  return base.join('\n');
}

function injectIntoFirstUser(output: any, text: string): void {
  if (!output?.messages?.length || !text) return;
  const firstUser = output.messages.find((m: any) => m?.info?.role === 'user');
  if (!firstUser || !Array.isArray(firstUser.parts) || firstUser.parts.length === 0) return;

  const alreadyInjected = firstUser.parts.some(
    (p: any) => p?.type === 'text' && typeof p.text === 'string' && p.text.includes('<POLICY_BLOCK>')
  );
  if (alreadyInjected) return;

  const ref = firstUser.parts[0];
  firstUser.parts.unshift({ ...ref, type: 'text', text });
}

export const CompanyPolicyPlugin = async () => {
  const configDir =
    normalizePath(process.env.OPENCODE_CONFIG_DIR) || path.join(os.homedir(), '.config', 'opencode');

  const policyPath = path.join(configDir, 'instructions', 'constitution.md');
  const policyContent = readPolicyFile(policyPath);

  return {
    config: async (config: any) => {
      config.instructions = config.instructions || {};
      config.instructions.policyPath = config.instructions.policyPath || policyPath;
    },

    'experimental.chat.messages.transform': async (_input: any, output: any) => {
      const latestUserText = extractLatestUserText(output?.messages || []);
      const policyBlock = buildPolicyBlock(policyContent, latestUserText);
      injectIntoFirstUser(output, policyBlock);
    },
  };
};

export default CompanyPolicyPlugin;
