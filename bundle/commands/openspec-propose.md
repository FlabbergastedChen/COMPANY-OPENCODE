---
description: "一键创建 change 并生成可进入实现前的关键制品。"
---

你正在执行命令 `/openspec-propose`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：一键创建 change 并生成可进入实现前的关键制品。
2. 优先按技能 `openspec-propose` 的工作方式执行。
3. 若参数缺失，基于上下文做最小假设并明确写出假设。
4. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- `openspec/changes/<change>/proposal.md`
- `openspec/changes/<change>/specs/*/spec.md`
- `openspec/changes/<change>/design.md`
- `openspec/changes/<change>/tasks.md`
- 输出简短执行摘要（已完成 / 未完成 / 风险）。

建议下一步：
- `/openspec-apply`
