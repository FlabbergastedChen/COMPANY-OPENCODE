---
description: "把 change 下 delta specs 同步到主 specs。"
---

你正在执行命令 `/openspec-sync`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：把 change 下 delta specs 同步到主 specs。
2. 优先按技能 `openspec-sync-specs` 的工作方式执行。
3. 若参数缺失，基于上下文做最小假设并明确写出假设。
4. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- `openspec/specs/*/spec.md` 更新结果
- 合并摘要（ADD/MODIFY/REMOVE/RENAME）
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
