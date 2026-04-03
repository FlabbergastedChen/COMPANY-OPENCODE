---
description: 基于现有设计制品生成可执行、按依赖有序的 tasks.md。
handoffs:
  - label: Analyze For Consistency
    agent: speckit.analyze
    prompt: Run a project analysis for consistency
    send: true
  - label: Implement Project
    agent: speckit.implement
    prompt: Start the implementation in phases
    send: true
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 执行前检查

读取 `.specify/extensions.yml` 的 `hooks.before_tasks`（规则同其他命令：解析失败静默跳过、enabled 过滤、condition 交给 HookExecutor、optional/mandatory 分流输出）。

## 纲要

1. 运行 `.specify/scripts/bash/check-prerequisites.sh --json`，解析 `FEATURE_DIR` 与 `AVAILABLE_DOCS`。
2. 读取设计文档：
   - 必需：`plan.md`、`spec.md`
   - 可选：`data-model.md`、`contracts/`、`research.md`、`quickstart.md`
3. 执行任务生成：
   - 从 spec 提取用户故事与优先级
   - 从 plan 提取技术栈、结构、约束
   - 把实体/接口/决策映射到故事任务
   - 生成按依赖有序、可并行标注的任务清单
4. 产出 `tasks.md`（基于 `.specify/templates/tasks-template.md`）：
   - Phase 1：Setup
   - Phase 2：Foundation
   - Phase 3+：每个用户故事一个 phase（按优先级）
   - Final：Polish/Cross-cutting
5. 输出摘要：总任务数、每故事任务数、并行机会、独立测试标准、建议 MVP。
6. 处理 `hooks.after_tasks`。

## 护栏

- 每个用户故事都应具备独立可验证交付。
- 任务必须可执行、可定位到文件路径。
- 不得生成无法验证的空泛任务。
