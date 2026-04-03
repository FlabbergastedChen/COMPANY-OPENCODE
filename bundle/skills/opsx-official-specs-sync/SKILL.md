---
name: opsx-official-specs-sync
description: 基于官方 openspec/specs/specs-sync-skill/spec.md 的本地离线技能；用于 delta specs 到主 specs 的智能同步。
---

[OPSX-OFFICIAL]

用途：离线等价规范同步能力。

执行要点：
1. 识别 ADDED / MODIFIED / REMOVED / RENAMED。
2. 对主 specs 做智能合并，保留未提及内容。
3. 同步结果应幂等（重复执行结果一致）。
