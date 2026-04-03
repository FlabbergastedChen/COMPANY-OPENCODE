---
description: "批量归档多个 change，处理可能的 spec 冲突。"
---

你正在执行命令 `/openspec-bulk-archive`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：批量归档多个 change，处理可能的 spec 冲突。
2. 优先按技能 `openspec-bulk-archive-change` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/openspec-bulk-archive-change/SKILL.md`，必要时再读 `~/.config/opencode/skills/openspec-bulk-archive-change/SKILL.md`。
4. 若参数缺失，基于上下文做最小假设并明确写出假设。
5. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 批量归档结果
- 冲突处理与同步摘要
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
