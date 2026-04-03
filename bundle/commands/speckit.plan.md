---
description: 使用计划模板执行实现规划工作流，并生成设计制品。
handoffs:
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 执行前检查

**检查扩展钩子（规划前）**：
- 检查项目根目录是否存在 `.specify/extensions.yml`。
- 若存在，读取 `hooks.before_plan`。
- YAML 无法解析时静默跳过。
- `enabled: false` 的钩子跳过；未声明 `enabled` 视为启用。
- 不在此处解释 `condition`：
  - 无 condition（或空）=> 可执行
  - 有非空 condition => 跳过，交给 HookExecutor
- 对可执行钩子按 `optional` 输出：
  - optional=true：展示可选命令与说明
  - optional=false：输出自动执行块并等待结果
- 若无钩子则静默继续。

## 纲要

1. **初始化**：在仓库根运行 `.specify/scripts/bash/setup-plan.sh --json`，解析 `FEATURE_SPEC`、`IMPL_PLAN`、`SPECS_DIR`、`BRANCH`。
2. **加载上下文**：读取 `FEATURE_SPEC` 与 `.specify/memory/constitution.md`，再加载 `IMPL_PLAN` 模板。
3. **执行规划流程**：
   - 填充 Technical Context（未知项标记 `NEEDS CLARIFICATION`）
   - 根据 constitution 填写 Constitution Check
   - 执行 gate 评估（违反且无正当理由则 ERROR）
   - Phase 0：产出 `research.md`（解决所有 NEEDS CLARIFICATION）
   - Phase 1：产出 `data-model.md`、`contracts/`、`quickstart.md`
   - Phase 1：运行 agent 上下文更新脚本
   - 设计后重新评估 Constitution Check
4. **停止并汇报**：命令在规划阶段结束，输出分支名、`IMPL_PLAN` 路径、生成制品。
5. **检查 after_plan 钩子**：逻辑与 before_plan 相同，读取 `hooks.after_plan`。

## 阶段

### Phase 0：调研

1. 从 Technical Context 提取未知项：
   - 每个 NEEDS CLARIFICATION → 调研任务
   - 每个依赖 → 最佳实践任务
   - 每个集成点 → 模式调研任务
2. 生成调研任务并汇总到 `research.md`：
   - Decision
   - Rationale
   - Alternatives considered

### Phase 1：设计制品

1. 基于 spec + research 生成：
   - `data-model.md`
   - `contracts/`
   - `quickstart.md`
2. 明确边界、约束、依赖与可验证标准。

### 质量要求

- 不得跳过 constitution 约束。
- 所有未知项必须在进入任务分解前收敛。
- 输出应可直接被 `/speckit.tasks` 消费。
