---
description: 批量归档多个已完成变更
---

一次性归档多个 change，并对 spec 冲突进行智能处理。

**输入**：无（通过交互选择）

**步骤**
1. 获取活动 change：`openspec list --json`。
2. 多选要归档的 change（可选 All）。
3. 批量校验每个 change 的 artifacts/tasks/delta specs。
4. 检测 capability 冲突（多个 change 同时修改同一 capability）。
5. 按代码实现证据决策冲突解法（只同步已实现项；都实现则按时间顺序应用）。
6. 单次确认后执行批量归档（含按策略同步 specs）。
7. 输出成功/跳过/失败汇总。

**护栏**
- 不自动选择 change
- 归档失败应按 change 级别隔离，不影响其他项继续
