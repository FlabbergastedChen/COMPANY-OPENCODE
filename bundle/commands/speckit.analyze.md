---
description: 在任务生成后，对 spec.md、plan.md、tasks.md 执行只读一致性与质量分析。
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 目标

在实现前识别三大核心制品（`spec.md`、`plan.md`、`tasks.md`）中的不一致、重复、歧义和欠定义项。该命令仅应在 `/speckit.tasks` 生成完整 `tasks.md` 后执行。

## 运行约束

- **严格只读**：不得修改任何文件。
- 输出结构化分析报告。
- 可附“修复建议计划”，但后续编辑需用户明确批准。
- **宪章优先级最高**：`.specify/memory/constitution.md` 与任何内容冲突时自动判定为 CRITICAL；应调整 spec/plan/tasks，而不是弱化宪章。

## 执行步骤

1. 运行 `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks`，解析 `FEATURE_DIR`、`AVAILABLE_DOCS`，并定位绝对路径：
   - SPEC=`FEATURE_DIR/spec.md`
   - PLAN=`FEATURE_DIR/plan.md`
   - TASKS=`FEATURE_DIR/tasks.md`
   缺失任一必要文件则终止并提示补齐前置命令。

2. 逐步加载最小必要上下文：
   - spec.md：概览、功能需求、成功标准、用户故事、边界场景
   - plan.md：架构/技术栈、数据模型引用、阶段、技术约束
   - tasks.md：任务 ID、描述、分组、并行标记、文件路径
   - constitution.md：原则与 MUST/SHOULD 约束

3. 构建内部语义模型：
   - 需求清单（FR/SC 键）
   - 用户动作清单
   - 任务覆盖映射（任务 ↔ 需求/故事）
   - 宪章规则集

4. 执行检测（高信号优先，最多 50 条发现）：
   - 重复检测
   - 歧义检测（模糊词、占位符）
   - 欠定义检测
   - 宪章对齐检测
   - 覆盖缺口检测
   - 跨文件术语/依赖/顺序不一致检测

5. 严重级别判定：
   - CRITICAL：宪章 MUST 冲突、核心需求零覆盖、阻断交付
   - HIGH：冲突需求、关键质量属性模糊、不可测试验收标准
   - MEDIUM：术语漂移、非功能覆盖不足、边界欠定义
   - LOW：表达改进与轻微整理

6. 生成报告：
   - Findings（按严重度）
   - Coverage Summary
   - Constitution Violations
   - Recommended Remediation Order（仅建议，不改文件）

## 输出要求

- 必须可执行（每条问题含影响、定位、修复方向）。
- 若证据不足，明确标注假设与不确定性。
