---
name: openspec-verify-change
description: 验证实现是否与 change 制品一致，作为归档前质量门禁。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于在归档前验证实现与 specs/tasks/design 的一致性。

## 验证维度
1. Completeness：任务与需求覆盖是否完整
2. Correctness：实现是否符合需求与场景
3. Coherence：是否遵循设计与项目模式

## 步骤
1. 选择 change 并读取 status。
2. 读取 apply contextFiles。
3. 产出 CRITICAL/WARNING/SUGGESTION 分级报告。
4. 输出是否 ready for archive 的结论。

## 护栏
- 每条问题要可执行、可定位
- 不确定时降低严重度，避免误报

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
