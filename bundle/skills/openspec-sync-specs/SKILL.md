---
name: openspec-sync-specs
description: 将 change 的 delta specs 智能合并到主 specs。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于把 delta specs 同步到主规范，支持智能局部合并。

## 步骤
1. 选择 change（需存在 delta specs）。
2. 读取 `opsx-official-specs-sync` 输入源。
3. 对主 specs 执行 ADDED/MODIFIED/REMOVED/RENAMED 合并。
4. 主 spec 不存在时创建新文件。
5. 输出同步摘要。

## 护栏
- 先读 delta 再读主 spec
- 保留未提及内容
- 结果应幂等

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
