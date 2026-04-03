---
description: "生成可执行实现计划（任务粒度小、可验证、无占位语）。"
---

你正在执行命令 `/superpowers-write-plan`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：生成可执行实现计划（任务粒度小、可验证、无占位语）。
2. 优先按技能 `superpowers-writing-plans` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/superpowers-writing-plans/SKILL.md`，必要时再读 `~/.config/opencode/skills/superpowers-writing-plans/SKILL.md`。
4. 若参数缺失，基于上下文做最小假设并明确写出假设。
5. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 实施计划文档
- 任务分解与验证步骤
- 输出简短执行摘要（已完成 / 未完成 / 风险）。

建议下一步：
- `/superpowers-execute-plan`
