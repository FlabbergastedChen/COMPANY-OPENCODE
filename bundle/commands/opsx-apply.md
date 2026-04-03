---
description: 从 OpenSpec 变更中实现任务（实验性）
---

从指定 change 的任务清单推进实现。

**输入**：`/opsx-apply [change-name]`

**步骤**
1. 选择 change（未提供时根据上下文推断；有歧义则 `openspec list --json` + AskUserQuestion）。
2. 读取状态：
```bash
openspec status --change "<name>" --json
```
3. 获取 apply 指令：
```bash
openspec instructions apply --change "<name>" --json
```
4. 读取 `contextFiles`。
5. 展示进度（schema、N/M、剩余任务、动态指令）。
6. 按任务循环实现：小步改动、完成即勾选 `- [ ]` → `- [x]`。
7. 完成或暂停时输出会话进度与下一步建议。

**暂停条件**
- 任务不清
- 发现设计冲突
- 遇到错误/阻塞
- 用户中断

**护栏**
- 先读上下文再改代码
- 不猜测需求
- 每完成一项立即更新任务状态
