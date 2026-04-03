---
description: 根据 tasks.md 执行实现计划并完成全部任务。
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 执行前检查

**检查扩展钩子（实现前）**：
- 读取 `.specify/extensions.yml` 的 `hooks.before_implement`。
- 解析失败静默跳过。
- `enabled: false` 跳过；未声明视为启用。
- condition 不在此解释，交给 HookExecutor。
- optional/mandatory 输出规则同 plan 命令。

## 纲要

1. 在仓库根运行 `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks`，解析 `FEATURE_DIR` 与文档列表。
2. **检查 checklist 完成度**（若存在 `FEATURE_DIR/checklists/`）：
   - 统计每个清单 total/completed/incomplete
   - 输出表格
   - 若存在未完成项，暂停并询问是否继续
3. 加载上下文：
   - 必需：`tasks.md`、`plan.md`
   - 可选：`data-model.md`、`contracts/`、`research.md`、`quickstart.md`
4. **项目忽略文件校验**：按技术栈检查/创建 `.gitignore`、`.dockerignore`、`.eslintignore`、`.prettierignore`、`.npmignore`、`.terraformignore`、`.helmignore`（按需）。
5. 按 `tasks.md` 顺序执行任务：
   - 小步实现、就近验证
   - 完成即勾选 `- [ ]`→`- [x]`
   - 记录阻塞与偏差
6. 输出实施结果：已完成项、剩余项、风险与后续动作。

## 护栏

- 先通过前置检查再实现。
- 不跳过高优先级阻塞。
- 若与 plan/spec 冲突，先停下并回报。
