---
name: opsx-official-verify
description: 基于官方 openspec/specs/opsx-verify-skill/spec.md 的本地离线技能；用于 Completeness/Correctness/Coherence 验证。
---

[OPSX-OFFICIAL]

用途：离线等价 `/opsx:verify` 验证能力。

验证维度：
1. Completeness：任务与需求覆盖。
2. Correctness：实现与规格场景一致性。
3. Coherence：实现与设计决策/项目模式一致性。

输出要求：
- CRITICAL / WARNING / SUGGESTION 分级。
- 每条问题给出可执行修复建议。
