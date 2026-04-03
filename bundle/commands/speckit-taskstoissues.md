---
description: "将 `tasks.md` 转为 issue 清单（用于项目管理平台）。"
---

你正在执行命令 `/speckit-taskstoissues`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：将 `tasks.md` 转为 issue 清单（用于项目管理平台）。
2. 优先按技能 `speckit-tasks-to-issues` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/speckit-tasks-to-issues/SKILL.md`，必要时再读 `~/.config/opencode/skills/speckit-tasks-to-issues/SKILL.md`。
4. 若参数缺失，基于上下文做最小假设并明确写出假设。
5. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 结构化 issue 草案（标题、描述、依赖、验收标准）
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
