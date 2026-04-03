---
name: opsx-official-cli-artifact-workflow
description: 基于官方 openspec/specs/cli-artifact-workflow/spec.md 的本地离线技能；覆盖 new/status/instructions/apply 指令语义。
---

[OPSX-OFFICIAL]

用途：离线等价承载 artifact 工作流能力。

能力面：
1. `new change`：创建 change 容器与基础结构。
2. `status`：返回 schemaName、isComplete、artifacts、applyRequires 等状态信息。
3. `instructions <artifact-id>`：返回创建该制品所需的 template/context/rules/outputPath/dependencies。
4. `instructions apply`：返回 apply 阶段的 contextFiles、instruction、tracks、applyRequires。

约束：
- 若依赖未满足，应明确 blocked 状态。
- 输出需支持 JSON 化消费。
