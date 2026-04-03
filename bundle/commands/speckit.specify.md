---
description: 从自然语言需求创建或更新 feature specification。
handoffs:
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
  - label: Clarify Spec Requirements
    agent: speckit.clarify
    prompt: Clarify specification requirements
    send: true
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 执行前检查

读取 `.specify/extensions.yml` 的 `hooks.before_specify`（解析失败静默跳过，enabled/condition/optional 处理规则同其它命令）。

## 纲要

1. 解析用户需求描述（若为空则报错）。
2. 生成 2-4 词短名（kebab-case）用于分支与特性标识。
3. 运行创建分支脚本（仅一次，必须 JSON 输出）：
   - `.specify/scripts/bash/create-new-feature.sh ... --json --short-name "<short-name>" "<description>"`
   - 若分支编号模式是 timestamp，附加 `--timestamp`
4. 从脚本输出读取 `BRANCH_NAME` 与 `SPEC_FILE`。
5. 加载 `.specify/templates/spec-template.md`，按模板填充：
   - 用户场景与测试
   - 功能需求（可测）
   - 成功标准（可量化、技术无关）
   - 关键实体（如涉及数据）
6. 对不明确点做“合理默认”，仅在高影响且无法合理默认时标注 `[NEEDS CLARIFICATION: ...]`（最多 3 处）。
7. 写回 `SPEC_FILE` 并输出结果摘要。
8. 检查 `hooks.after_specify`。

## 护栏

- 不要求用户重复已输入内容。
- 需求必须可测，避免空泛描述。
- 仅在必要时引入澄清标记，控制在高影响问题上。
