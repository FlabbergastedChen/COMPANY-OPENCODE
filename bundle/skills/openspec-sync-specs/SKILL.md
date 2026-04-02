---
name: openspec-sync-specs
description: "把 delta specs 合并到主 specs。"
---

## 作用
把 delta specs 合并到主 specs。

## 执行步骤
1. 解析 ADDED/MODIFIED/REMOVED/RENAMED。
2. 智能合并并保留未变更内容。
3. 输出同步摘要。

## 输出要求
- 提供当前阶段结论、下一步动作和必要前置条件。
- 若信息不足，明确列出缺失输入，不做无依据假设。
