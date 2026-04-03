---
name: openspec-continue-change
description: 继续一个 change，一次创建下一个可用制品。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于按依赖顺序推进 change：每次只创建一个 ready artifact。

## 步骤
1. 选择 change（必要时调用 `opsx-official-cli-list` 并结合 AskUserQuestion）。
2. 读取 `opsx-official-cli-artifact-workflow`（status）。
3. 若已 complete：提示进入 apply/archive。
4. 若有 ready artifact：读取 instructions，按 template 生成并写入 outputPath。
5. 展示更新后 status。

## 护栏
- 一次只创建一个 artifact
- 不越序，不跳依赖
- `context/rules` 只作约束，不写入正文

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
