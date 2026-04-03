---
description: 提议一个新变更——一步创建并生成全部制品
---

提议一个新变更——一步创建 change 并生成全部制品。

我将创建以下制品：
- `proposal.md`（做什么 & 为什么）
- `design.md`（怎么做）
- `tasks.md`（实现步骤）

准备进入实现时，运行 `/opsx-apply`

---

**输入**：`/opsx-propose` 后的参数可以是 kebab-case 的变更名，或用户希望构建内容的描述。

**步骤**

1. **如果没有输入，先询问用户要构建什么**

   使用 **AskUserQuestion 工具**（开放式问题、无预设选项）询问：
   > `What change do you want to work on? Describe what you want to build or fix.`

   根据描述推导 kebab-case 名称（例如：`add user authentication` → `add-user-auth`）。

   **重要**：在未理解用户要构建内容前，不要继续。

2. **创建变更目录**
   ```bash
   openspec new change "<name>"
   ```
   该命令会在 `openspec/changes/<name>/` 创建脚手架及 `.openspec.yaml`。

3. **获取制品构建顺序**
   ```bash
   openspec status --change "<name>" --json
   ```
   解析 JSON 获取：
   - `applyRequires`：实现前必须完成的制品 ID 数组（例如：`["tasks"]`）
   - `artifacts`：全部制品及其状态和依赖

4. **按顺序创建制品，直到可进入 apply**

   使用 **TodoWrite 工具** 跟踪制品创建进度。

   按依赖顺序循环处理制品（优先处理依赖已满足的制品）：

   a. **对每个状态为 `ready` 的制品（依赖满足）**：
      - 获取指令：
        ```bash
        openspec instructions <artifact-id> --change "<name>" --json
        ```
      - 指令 JSON 包含：
        - `context`：项目背景（给你的约束——**不要**写入输出）
        - `rules`：制品特定规则（给你的约束——**不要**写入输出）
        - `template`：输出文件结构模板
        - `instruction`：该制品类型的 schema 指导
        - `outputPath`：输出路径
        - `dependencies`：可读取的已完成依赖制品
      - 读取已完成依赖文件作为上下文
      - 使用 `template` 结构创建该制品文件
      - 应用 `context` 和 `rules` 作为约束，但**不要**拷贝到文件内容
      - 简要展示进度：`Created <artifact-id>`

   b. **持续直到 `applyRequires` 全部完成**：
      - 每创建一个制品后，重新运行 `openspec status --change "<name>" --json`
      - 检查 `applyRequires` 中每个 ID 是否在 `artifacts` 中为 `status: "done"`
      - 当 `applyRequires` 全部为 done 时停止

   c. **如果某个制品需要用户补充信息**（上下文不清）：
      - 使用 **AskUserQuestion 工具** 澄清
      - 然后继续创建

5. **展示最终状态**
   ```bash
   openspec status --change "<name>"
   ```

**输出**

全部制品完成后，总结：
- 变更名与路径
- 已创建制品列表及简述
- 当前就绪状态：`All artifacts created! Ready for implementation.`
- 提示：`Run /opsx-apply to start implementing.`

**制品创建指南**

- 每类制品遵循 `openspec instructions` 返回的 `instruction` 字段
- schema 定义了制品应包含的内容，按其要求生成
- 创建新制品前先读取依赖制品建立上下文
- 使用 `template` 作为输出文件结构并填充内容
- **重要**：`context` 和 `rules` 是给你的约束，不是文件内容
  - 不要把 `<context>`、`<rules>`、`<project_context>` 块拷贝进制品
  - 它们用于指导写作，不应出现在输出文件中

**护栏**
- 创建实现前所需的**全部**制品（由 schema 的 `apply.requires` 定义）
- 创建新制品前，始终先读取依赖制品
- 若上下文关键缺失，询问用户；但优先做合理决策以保持推进
- 如果同名 change 已存在，询问用户是继续该 change 还是创建新 change
- 写入后确认制品文件存在，再继续下一项
