---
name: openspec-propose
description: 一步创建 change 并生成实现前关键制品。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于快速把需求转换成可实现的 OpenSpec change（含 proposal/spec/design/tasks 等）。

## 步骤
1. 澄清输入并推导 change 名。
2. 创建 change：调用 `opsx-official-cli-artifact-workflow`（new change）。
3. 读取 status 获取依赖顺序。
4. 为每个 ready artifact 读取 instructions 并生成文件。
5. 持续到 `applyRequires` 全部完成。
6. 输出可进入 `/opsx-apply` 的状态。

## 护栏
- `context/rules` 不写入产物
- 同名 change 已存在时先确认处理方式

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
