---
name: opsx-official-cli-list
description: 基于官方 openspec/specs/cli-list/spec.md 的本地离线技能；用于列出 change 并支持后续选择。
---

[OPSX-OFFICIAL]

用途：离线等价实现 `openspec list --json` 的语义，用于获取活动 changes 列表。

执行要点：
1. 返回活动 changes 集合（不含已归档）。
2. 输出结构应可用于后续选择（name、schema、状态摘要）。
3. 上游调用方可结合 AskUserQuestion 做交互选择。
