---
description: 从 OpenSpec 变更中实现任务（实验性）
---

从 OpenSpec 变更中实现任务。

**输入**：可选地指定变更名称（例如：`/opsx-apply add-auth`）。如果省略，检查是否可从对话上下文推断。如果含糊或有歧义，你**必须**提示可用变更供用户选择。

**步骤**

1. **选择变更**

   如果提供了名称，则直接使用。否则：
   - 如果用户在对话中提到过变更，则从上下文推断
   - 如果仅有一个活动变更，则自动选择
   - 如果有歧义，运行 `openspec list --json` 获取可用变更，并使用 **AskUserQuestion 工具** 让用户选择

   始终要告知：`Using change: <name>`，并说明如何覆盖（例如：`/opsx-apply <other>`）。

2. **检查状态以理解 schema**
   ```bash
   openspec status --change "<name>" --json
   ```
   解析 JSON 以理解：
   - `schemaName`：当前使用的工作流（例如：`spec-driven`）
   - 哪个制品包含任务（通常 `spec-driven` 是 `tasks`，其他 schema 以 status 结果为准）

3. **获取 apply 指令**

   ```bash
   openspec instructions apply --change "<name>" --json
   ```

   该命令会返回：
   - 上下文文件路径（随 schema 不同而变化）
   - 进度（total、complete、remaining）
   - 带状态的任务列表
   - 基于当前状态动态生成的指令

   **处理状态：**
   - 如果 `state: "blocked"`（缺少制品）：显示提示，并建议使用 `/opsx-continue`
   - 如果 `state: "all_done"`：祝贺用户并建议归档
   - 其他情况：继续实现

4. **读取上下文文件**

   读取 apply 指令输出中的 `contextFiles` 列表。
   文件取决于所用 schema：
   - **spec-driven**：proposal、specs、design、tasks
   - 其他 schema：以 CLI 输出的 `contextFiles` 为准

5. **展示当前进度**

   显示：
   - 当前使用的 schema
   - 进度：`N/M tasks complete`
   - 剩余任务概览
   - CLI 返回的动态指令

6. **实现任务（循环直到完成或阻塞）**

   对每个待处理任务：
   - 展示当前正在处理的任务
   - 进行所需代码修改
   - 保持改动最小且聚焦
   - 在任务文件中标记完成：`- [ ]` → `- [x]`
   - 继续下一项任务

   **以下情况暂停：**
   - 任务不清晰 → 请求澄清
   - 实现暴露设计问题 → 建议更新制品
   - 出现错误或阻塞 → 报告并等待指导
   - 用户中断

7. **完成或暂停时展示状态**

   显示：
   - 本次会话完成的任务
   - 总体进度：`N/M tasks complete`
   - 若全部完成：建议归档
   - 若已暂停：说明原因并等待指导

**实现过程输出**

```
## Implementing: <change-name> (schema: <schema-name>)

Working on task 3/7: <task description>
[...implementation happening...]
✓ Task complete

Working on task 4/7: <task description>
[...implementation happening...]
✓ Task complete
```

**完成时输出**

```
## Implementation Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 7/7 tasks complete ✓

### Completed This Session
- [x] Task 1
- [x] Task 2
...

All tasks complete! You can archive this change with `/opsx-archive`.
```

**暂停时输出（遇到问题）**

```
## Implementation Paused

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 4/7 tasks complete

### Issue Encountered
<description of the issue>

**Options:**
1. <option 1>
2. <option 2>
3. Other approach

What would you like to do?
```

**护栏**
- 持续推进任务，直到完成或阻塞
- 开始前必须先读取上下文文件（来自 apply 指令输出）
- 如果任务含糊，先暂停并询问，再实现
- 如果实现中发现问题，先暂停并建议更新制品
- 代码改动保持最小且与当前任务范围一致
- 每完成一项任务，立即更新复选框
- 遇到错误、阻塞或需求不清时暂停，不要猜测
- 使用 CLI 输出中的 `contextFiles`，不要假设固定文件名

**流式工作流集成**

该技能支持“对变更执行动作”的模型：

- **可随时调用**：可在制品未全部完成前调用（只要已有任务）、可在部分实现后调用、也可与其他动作交错
- **允许更新制品**：若实现暴露设计问题，可建议更新制品；不强制锁定阶段，支持流式推进
