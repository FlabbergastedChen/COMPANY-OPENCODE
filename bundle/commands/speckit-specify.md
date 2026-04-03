---
description: "将自然语言需求转为 Spec-Kit 风格规范文档。"
---

你正在执行命令 `/speckit-specify`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：将自然语言需求转为 Spec-Kit 风格规范文档。
2. 优先按技能 `speckit-feature-specification` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/speckit-feature-specification/SKILL.md`，必要时再读 `~/.config/opencode/skills/speckit-feature-specification/SKILL.md`。
4. 需要协作时可结合：`speckit-checklist-generation`。
5. 若参数缺失，基于上下文做最小假设并明确写出假设。
6. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- `specs/<feature>/spec.md`
- 输出简短执行摘要（已完成 / 未完成 / 风险）。

建议下一步：
- 歧义多：`/speckit-clarify`
- 歧义可控：`/speckit-plan`
