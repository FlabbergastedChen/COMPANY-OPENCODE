---
name: opsx-official-cli-archive
description: 基于官方 openspec/specs/cli-archive/spec.md 的本地离线技能；用于归档单个或批量 change 的归档动作语义。
---

[OPSX-OFFICIAL]

用途：离线等价归档能力。

执行要点：
1. 归档目标目录规则：`openspec/changes/archive/YYYY-MM-DD-<name>`。
2. 归档前可结合状态与任务完成度做警告提示。
3. 若目标已存在，应返回可操作错误而非静默覆盖。
