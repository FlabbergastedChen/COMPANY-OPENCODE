---
description: "在宣称完成前强制执行验证门禁。"
---

你正在执行命令 `/superpowers-verify`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：在宣称完成前强制执行验证门禁。
2. 优先按技能 `superpowers-verification-before-completion` 的工作方式执行。
3. 若参数缺失，基于上下文做最小假设并明确写出假设。
4. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 验证证据
- 结论：Ready / Not Ready
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
