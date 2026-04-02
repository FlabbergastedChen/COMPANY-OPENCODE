---
description: "归档单个 change，并保留追溯信息。"
---

你正在执行命令 `/openspec-archive`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：归档单个 change，并保留追溯信息。
2. 优先按技能 `openspec-archive-change` 的工作方式执行。
3. 若参数缺失，基于上下文做最小假设并明确写出假设。
4. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- `openspec/changes/archive/YYYY-MM-DD-<change>/`
- 归档摘要与警告（如有）
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
