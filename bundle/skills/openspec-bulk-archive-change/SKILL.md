---
name: openspec-bulk-archive-change
description: 批量归档多个 change，并在冲突场景下智能决策 specs 同步顺序。
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.2.0"
---

用于批量归档多个 change。

## 步骤
1. 获取活动 changes 并多选。
2. 批量收集 artifacts/tasks/delta specs 状态。
3. 检测 capability 冲突。
4. 依据代码实现证据决定同步策略与顺序。
5. 单次确认后批量执行 sync + archive。
6. 输出成功/跳过/失败汇总。

## 护栏
- 不自动选择
- 冲突先判定后执行
- 单个失败不应阻断其他 change

## 工具映射（基于 OpenSpec specs）
- 列出/选择 change：`opsx-official-cli-list`
- 状态/指引/创建变更：`opsx-official-cli-artifact-workflow`
- 归档：`opsx-official-cli-archive`
- 规范同步：`opsx-official-specs-sync`
- 实现验证：`opsx-official-verify`

说明：本技能优先使用上述能力映射，不依赖模型直接理解 `openspec ...` 原始命令字符串。
