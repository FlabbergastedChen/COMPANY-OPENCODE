---
name: openspec-onboard
description: 引导用户完成一次端到端 OpenSpec 入门实战。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于新手 onboarding：从任务选择到归档，完整演示一次 OpenSpec 周期。

## 阶段
1. 预检 CLI
2. 扫描代码库并推荐小任务
3. 演示 explore
4. 创建 change
5. 依次完成 proposal/specs/design/tasks
6. apply 实现与 verify
7. archive 收口

## 执行要求
- 每阶段先讲“为什么”再执行
- 关键节点暂停等待用户确认
- 任务过大时建议切片，但保留用户最终选择权

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
