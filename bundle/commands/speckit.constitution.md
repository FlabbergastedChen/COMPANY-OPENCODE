---
description: 通过交互式输入或已有原则更新项目宪章，并同步相关模板。
handoffs:
  - label: Build Specification
    agent: speckit.specify
    prompt: Implement the feature specification based on the updated constitution. I want to build...
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 纲要

你正在更新 `.specify/memory/constitution.md`。该文件是带占位符的模板（如 `[PROJECT_NAME]`、`[PRINCIPLE_1_NAME]`）。你的职责是：
1. 收集/推导占位符值；
2. 精确替换模板；
3. 将修订同步到依赖模板与文档。

说明：若 `.specify/memory/constitution.md` 不存在，先从 `.specify/templates/constitution-template.md` 复制初始化。

执行流程：

1. 读取现有宪章，识别所有 `[ALL_CAPS_IDENTIFIER]` 占位符。
   - 若用户指定原则数量，按用户要求调整，不强行沿用模板默认数量。

2. 收集/推导占位符值：
   - 用户明确给出的值优先。
   - 其次从仓库上下文推导（README、docs、历史宪章）。
   - 日期规则：
     - `RATIFICATION_DATE`：首次采纳日期（未知可询问或标注 TODO）
     - `LAST_AMENDED_DATE`：若有改动则为今天，否则保持原值
   - 版本规则（语义化版本）：
     - MAJOR：不兼容治理变更、原则删除或重定义
     - MINOR：新增原则/章节或实质性扩展
     - PATCH：措辞澄清、错别字、非语义调整
   - 若 bump 类型不明确，先给出理由再确定。

3. 起草更新后的宪章：
   - 替换所有占位符（除非明确保留并解释原因）。
   - 保持标题层级不变。
   - 每条原则应包含：名称、不可妥协规则、必要时附简短 rationale。
   - Governance 必须覆盖：修订流程、版本策略、合规检查期望。

4. 一致性传播检查（主动执行）：
   - 检查 `.specify/templates/plan-template.md` 的 Constitution Check 是否与新原则一致。
   - 检查 `.specify/templates/spec-template.md` 是否与新强制约束一致。
   - 检查 `.specify/templates/tasks-template.md` 是否反映新的任务类型要求。
   - 检查 `.specify/templates/commands/*.md` 是否存在过时引用。
   - 检查运行说明文档（README、quickstart 等）与新原则一致性。

5. 生成同步影响报告（写入宪章顶部 HTML 注释）：
   - 版本变化：old → new
   - 修改的原则列表（含重命名）
   - 新增/删除章节
   - 受影响模板状态（✅ 已更新 / ⚠ 待处理）
   - 延后处理项（如有）

6. 输出前校验：
   - 不应残留未解释占位符。
   - 版本与报告一致。
   - 日期格式为 YYYY-MM-DD。
   - 规则可执行、可验证，避免空泛措辞。

7. 覆盖写回 `.specify/memory/constitution.md`。

8. 向用户输出总结：
   - 新版本与 bump 理由
   - 需人工跟进的文件
   - 建议 commit message（例如：`docs: amend constitution to vX.Y.Z (principle additions + governance update)`）

格式要求：
- 保持模板原有 Markdown 标题层级。
- 优先可读性（建议每行 <100 字符），但不机械换行。
- 仅保留有价值注释。
