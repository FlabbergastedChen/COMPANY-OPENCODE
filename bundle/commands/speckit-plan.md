---
description: "将规格转为技术实现计划与设计制品。"
---

你正在执行命令 `/speckit-plan`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：将规格转为技术实现计划与设计制品。
2. 优先按技能 `speckit-technical-planning` 的工作方式执行。
3. 若参数缺失，基于上下文做最小假设并明确写出假设。
4. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- `specs/<feature>/plan.md`
- 可选：`data-model.md`、`contracts/`、`quickstart.md`
- 输出简短执行摘要（已完成 / 未完成 / 风险）。

建议下一步：
- `/speckit-tasks`
