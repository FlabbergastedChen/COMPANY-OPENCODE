---
description: "先设计后实现，避免直接进入编码导致返工。"
---

你正在执行命令 `/superpowers-brainstorm`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：先设计后实现，避免直接进入编码导致返工。
2. 优先按技能 `superpowers-brainstorming` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/superpowers-brainstorming/SKILL.md`，必要时再读 `~/.config/opencode/skills/superpowers-brainstorming/SKILL.md`。
4. 内置流程（无技能工具时必须执行）：
   - 理解上下文与约束
   - 给出 2-3 个可行方案及取舍
   - 给出推荐设计，并明确“确认前不进入实现”
5. 若参数缺失，基于上下文做最小假设并明确写出假设。
6. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 方案对比
- 推荐设计
- 下一步建议：`/superpowers-write-plan`
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
