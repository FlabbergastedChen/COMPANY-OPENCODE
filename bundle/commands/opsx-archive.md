---
description: 在实验性工作流中归档已完成变更
---

在实验性工作流中归档已完成变更。

**输入**：可在 `/opsx-archive` 后可选指定变更名（例如：`/opsx-archive add-auth`）。如果省略，检查是否可从对话上下文推断。如果含糊或有歧义，你**必须**提示可用变更供用户选择。

**步骤**

1. **如果未提供变更名，提示用户选择**

   运行 `openspec list --json` 获取可用变更。使用 **AskUserQuestion 工具** 让用户选择。

   仅展示活动中的变更（不含已归档）。
   如可获取，展示每个变更使用的 schema。

   **重要**：不要猜测或自动选择变更。必须由用户选择。

2. **检查制品完成状态**

   运行 `openspec status --change "<name>" --json` 检查制品完成情况。

   解析 JSON 以理解：
   - `schemaName`：当前使用的工作流
   - `artifacts`：制品列表及其状态（`done` 或其他）

   **如果任一制品不是 `done`：**
   - 显示警告并列出未完成制品
   - 询问用户是否继续
   - 用户确认后继续

3. **检查任务完成状态**

   读取任务文件（通常是 `tasks.md`）检查是否存在未完成任务。

   统计 `- [ ]`（未完成）与 `- [x]`（已完成）。

   **如果发现未完成任务：**
   - 显示警告并展示未完成任务数量
   - 询问用户是否继续
   - 用户确认后继续

   **如果不存在任务文件：** 无任务相关警告，继续执行。

4. **评估 delta spec 同步状态**

   检查 `openspec/changes/<name>/specs/` 是否存在 delta specs。若不存在，则无需同步提示并继续。

   **如果存在 delta specs：**
   - 将每个 delta spec 与主 spec `openspec/specs/<capability>/spec.md` 对比
   - 判断将要应用的变化（新增、修改、删除、重命名）
   - 在询问前展示合并后的变更摘要

   **提示选项：**
   - 若需要同步：`Sync now (recommended)`、`Archive without syncing`
   - 若已同步：`Archive now`、`Sync anyway`、`Cancel`

   如果用户选择同步，使用 Task 工具（`subagent_type: "general-purpose"`，prompt: `Use Skill tool to invoke openspec-sync-specs for change '<name>'. Delta spec analysis: <include the analyzed delta spec summary>`）。无论用户选择哪项，之后都继续归档流程。

5. **执行归档**

   若归档目录不存在则创建：
   ```bash
   mkdir -p openspec/changes/archive
   ```

   使用当前日期生成目标目录名：`YYYY-MM-DD-<change-name>`

   **检查目标是否已存在：**
   - 若已存在：报错并建议重命名现有归档或换日期
   - 若不存在：移动变更目录到归档

   ```bash
   mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>
   ```

6. **展示摘要**

   显示归档完成摘要，包括：
   - 变更名
   - 使用的 schema
   - 归档位置
   - Spec 同步状态（已同步 / 跳过同步 / 无 delta specs）
   - 所有警告说明（如制品/任务未完成）

**成功输出**

```
## Archive Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** ✓ Synced to main specs

All artifacts complete. All tasks complete.
```

**成功输出（无 Delta Specs）**

```
## Archive Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** No delta specs

All artifacts complete. All tasks complete.
```

**成功输出（含警告）**

```
## Archive Complete (with warnings)

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** Sync skipped (user chose to skip)

**Warnings:**
- Archived with 2 incomplete artifacts
- Archived with 3 incomplete tasks
- Delta spec sync was skipped (user chose to skip)

Review the archive if this was not intentional.
```

**错误输出（归档目录已存在）**

```
## Archive Failed

**Change:** <change-name>
**Target:** openspec/changes/archive/YYYY-MM-DD-<name>/

Target archive directory already exists.

**Options:**
1. Rename the existing archive
2. Delete the existing archive if it's a duplicate
3. Wait until a different date to archive
```

**护栏**
- 如果未提供变更名，必须提示用户选择
- 使用 artifact graph（`openspec status --json`）检查完成情况
- 对警告不强阻断归档，但要提示并确认
- 移动目录时保留 `.openspec.yaml`（会随目录一起移动）
- 清晰展示最终结果摘要
- 若请求同步，使用 Skill 工具调用 `openspec-sync-specs`（agent 驱动）
- 若存在 delta specs，必须先完成同步评估并展示合并摘要再询问用户
