---
name: openspec-new-change
description: 创建新 change 并展示首个制品指引，不自动创建全部制品。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于创建新的 OpenSpec change，并停在“首个制品模板”阶段。

## 步骤
1. 获取或推导 kebab-case 变更名。
2. 按需确定 schema（默认不传 `--schema`）。
3. 执行 `opsx-official-cli-artifact-workflow`（new change）。
4. 执行 `opsx-official-cli-artifact-workflow`（status） 查看制品状态。
5. 获取首个 ready artifact 的 instructions。
6. 停止并等待用户下一步指令。

## 输出
- change 目录
- schema 与 artifact 序列
- 首个 artifact 模板

## 护栏
- 不创建制品内容
- 不越过首个模板展示阶段

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
