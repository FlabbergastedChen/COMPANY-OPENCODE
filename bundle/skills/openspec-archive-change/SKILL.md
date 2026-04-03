---
name: openspec-archive-change
description: 归档单个已完成 change，并给出同步与风险提示。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于归档单个 change。

## 步骤
1. 选择 change。
2. 检查 artifacts 完成度。
3. 检查 tasks 完成度。
4. 若有 delta specs，先评估是否 sync。
5. 执行归档到 `opsx-official-cli-archive` 归档目标。
6. 输出归档摘要与警告。

## 护栏
- 未提供 change 时必须询问
- 有警告可继续，但需用户确认
- 目标目录已存在时报错并给选项

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
