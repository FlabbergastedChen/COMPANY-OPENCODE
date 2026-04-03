---
description: "系统化定位问题根因，并在可行时并行调查。"
---

你正在执行命令 `/superpowers-debug`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：系统化定位问题根因，并在可行时并行调查。
2. 优先按技能 `superpowers-systematic-debugging` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/superpowers-systematic-debugging/SKILL.md`，必要时再读 `~/.config/opencode/skills/superpowers-systematic-debugging/SKILL.md`。
4. 需要协作时可结合：`superpowers-dispatching-parallel-agents`。
5. 若参数缺失，基于上下文做最小假设并明确写出假设。
6. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 根因报告
- 修复与回归建议
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
