---
name: openspec-apply-change
description: 按 change 任务清单执行实现，并持续更新任务进度。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于从 change 的 tasks 推进实现。

## 步骤
1. 选择 change。
2. 读取 status（schema、任务承载制品）。
3. 读取 apply instructions 与 contextFiles。
4. 展示进度并逐项实现任务。
5. 每完成一项任务即勾选完成。
6. 完成或阻塞时输出摘要。

## 暂停条件
- 任务不清
- 设计冲突
- 错误或阻塞
- 用户中断

## 护栏
- 改动最小且聚焦
- 先读上下文再实现
- 不清楚就先问，不猜

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
