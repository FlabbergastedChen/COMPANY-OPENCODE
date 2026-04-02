---
description: "按计划执行实现，并在阻塞时停止猜测。"
---

你正在执行命令 `/superpowers-execute-plan`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：按计划执行实现，并在阻塞时停止猜测。
2. 优先按技能 `superpowers-executing-plans` 的工作方式执行。
3. 需要协作时可结合：`superpowers-subagent-driven-development`。
4. 若参数缺失，基于上下文做最小假设并明确写出假设。
5. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 代码改动
- 任务进度
- 阻塞项与处理建议
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
