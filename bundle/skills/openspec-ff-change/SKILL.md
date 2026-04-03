---
name: openspec-ff-change
description: 快速补齐实现前制品，直到 apply-ready。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于批量创建实现前所需制品（按依赖顺序），直到可进入 apply。

## 步骤
1. 选择 change。
2. 读取 status，定位 ready artifact。
3. 循环读取 instructions 并创建制品。
4. 每轮刷新 status，直到 `applyRequires` 全部完成。
5. 输出 apply-ready 状态。

## 护栏
- 仅创建制品，不实现业务代码
- 严格依赖顺序

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
