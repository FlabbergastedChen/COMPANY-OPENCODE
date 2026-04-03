---
description: 对当前 feature spec 的高影响歧义发起最多 5 个定向问题，并将答案回写到 spec。
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 目标

识别并收敛活动 spec 中的关键歧义/缺失决策点，将澄清结果直接写回 spec，降低后续返工。

## 执行步骤

1. 在仓库根运行 `.specify/scripts/bash/check-prerequisites.sh --json --paths-only`，解析 `FEATURE_DIR`、`FEATURE_SPEC`。
2. 加载 spec，按分类扫描（Clear / Partial / Missing）：
   - 功能范围与行为
   - 领域与数据模型
   - 交互与 UX 流程
   - 非功能属性（性能/可靠性/安全/可观测）
   - 外部依赖与集成
   - 边界与失败场景
   - 术语一致性与验收可测性
3. 生成候选澄清问题并按影响优先级排序（最多 5 个）。
4. 逐个提问（一次只问 1 个）：
   - 若可选项明确，给 2-5 个选项
   - 给出推荐选项与简短理由
   - 用户可选字母、接受推荐或给短答案
5. 收敛后回写 spec（保持结构），并消除已解决歧义标记。
6. 输出澄清摘要与后续建议（通常进入 `/speckit.plan`）。

## 护栏

- 只问“会影响实现/验证”的问题。
- 避免重复询问用户已明确的信息。
- 若用户明确跳过澄清，允许继续但必须提示返工风险。
