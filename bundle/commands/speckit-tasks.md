---
description: "生成依赖有序、可执行的任务清单。"
---

你正在执行命令 `/speckit-tasks`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：生成依赖有序、可执行的任务清单。
2. 优先按技能 `speckit-task-generation` 的工作方式执行。
3. 若参数缺失，基于上下文做最小假设并明确写出假设。
4. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- `specs/<feature>/tasks.md`
- 输出简短执行摘要（已完成 / 未完成 / 风险）。

建议下一步：
- 推荐先跑 `/speckit-analyze`
- 再执行 `/speckit-implement`
