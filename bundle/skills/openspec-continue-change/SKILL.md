---
name: openspec-continue-change
description: "增量生成下一个依赖满足的 artifact。"
---

## 作用
增量生成下一个依赖满足的 artifact。

## 执行步骤
1. 读取 change 状态。
2. 选择 next-ready artifact。
3. 生成并报告后续可用项。

## 输出要求
- 提供当前阶段结论、下一步动作和必要前置条件。
- 若信息不足，明确列出缺失输入，不做无依据假设。
