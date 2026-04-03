---
description: 归档前验证实现是否与变更制品一致
---

验证实现是否匹配 change 的 specs/tasks/design。

**输入**：`/opsx-verify [change-name]`

**步骤**
1. 选择 change（`openspec list --json` + AskUserQuestion）。
2. 读取状态：`openspec status --change "<name>" --json`。
3. 拉取 apply 上下文：`openspec instructions apply --change "<name>" --json`。
4. 按三维度生成验证报告：
- Completeness（任务与需求覆盖）
- Correctness（实现与场景匹配）
- Coherence（设计遵循与模式一致性）
5. 输出 CRITICAL/WARNING/SUGGESTION 分级问题与最终结论。

**护栏**
- 每条问题必须可执行、可定位
- 不确定时降低严重级别，避免误报
