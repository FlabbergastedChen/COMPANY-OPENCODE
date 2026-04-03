---
name: openspec-explore
description: 探索模式：用于思考、调查与澄清，不直接实现。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

探索模式是“思考伙伴”模式，不是实现模式。

## 可做
- 调查代码库与现状
- 提出澄清问题与方案对比
- 用 ASCII 图辅助表达
- 在用户要求下创建/更新 OpenSpec 制品

## 不可做
- 不写业务实现代码
- 不自动替用户落盘关键决策

## OpenSpec 感知
- 可先 `opsx-official-cli-list` 获取活动 changes
- 需要时读取 change 的 proposal/design/tasks 参与讨论

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
