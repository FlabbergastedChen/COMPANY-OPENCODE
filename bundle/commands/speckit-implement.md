---
description: "按 `tasks.md` 分阶段执行实现。"
---

你正在执行命令 `/speckit-implement`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先对齐本命令目标：按 `tasks.md` 分阶段执行实现。
2. 优先按技能 `speckit-implementation-runner` 的工作方式执行。
3. 若 Skill 工具调用失败，回退读取本地文件：`$OPENCODE_CONFIG_DIR/skills/speckit-implementation-runner/SKILL.md`，必要时再读 `~/.config/opencode/skills/speckit-implementation-runner/SKILL.md`。
4. 需要协作时可结合：`executing-plans`。
5. 若参数缺失，基于上下文做最小假设并明确写出假设。
6. 若出现阻塞，输出阻塞原因、影响范围与建议解法，不做无依据猜测。

输出要求：
- 代码改动
- 任务进度
- 验证证据
- 输出简短执行摘要（已完成 / 未完成 / 风险）。
