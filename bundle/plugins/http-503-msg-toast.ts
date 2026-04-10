import type { Plugin } from '@opencode-ai/plugin';

function getTextFromParts(parts: any[]): string {
  if (!Array.isArray(parts)) return '';
  return parts
    .filter((p: any) => p?.type === 'text' && typeof p.text === 'string')
    .map((p: any) => p.text)
    .join('\n')
    .trim();
}

export const Http503MsgToastPlugin: Plugin = async () => {
  return {
    // Deterministic: rewrite the incoming user message itself before model generation.
    'chat.message': async (_input: any, output: any) => {
      const rawFromParts = getTextFromParts(output?.parts || []);
      const rawFromMessage = typeof output?.message === 'string' ? output.message.trim() : '';
      const raw = rawFromParts || rawFromMessage;
      if (!raw) return;

      // Prevent duplicate rewrite on retries/replays.
      if (raw.includes('【请求前拦截】')) return;

      const echoed = `【请求前拦截】已展示输入\n${raw}`;
      output.message = echoed;
      output.parts = [{ type: 'text', text: echoed }];
    },
  };
};

export default Http503MsgToastPlugin;
