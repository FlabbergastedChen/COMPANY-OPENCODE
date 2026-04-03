---
description: 根据当前特性与用户关注点生成自定义需求质量检查清单。
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 核心定义

Checklist 是“需求文档质量的单元测试”，用于检验需求本身是否完整、清晰、一致、可测；**不是**验证实现是否正确。

## 执行步骤

1. 运行 `.specify/scripts/bash/check-prerequisites.sh --json`，解析 `FEATURE_DIR` 与可用文档。
2. 基于用户输入与文档上下文动态提出最多 3 个澄清问题（必要时可追加到 5 个），仅询问会实质影响清单内容的信息。
3. 读取上下文（spec/plan/tasks），按关注域抽取高影响场景。
4. 在 `FEATURE_DIR/checklists/` 生成或追加 `[domain].md`：
   - 文件不存在：从 CHK001 开始
   - 文件已存在：续号追加，不覆盖历史内容
5. 按“需求质量维度”组织条目：
   - Completeness
   - Clarity
   - Consistency
   - Measurability
   - Scenario / Edge Cases
   - Non-Functional
   - Dependencies / Assumptions

## 写作规则

- 每条检查项必须在“检查需求文本质量”，不是检查代码行为。
- 条目必须可判定（通过/不通过）。
- 避免空泛形容词，尽量量化。

## 输出

- 清单文件路径
- 新增条目数量
- 仍待澄清的关键空白（如有）
