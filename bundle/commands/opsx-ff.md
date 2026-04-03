---
description: 快速前置（自动补齐实现前所需制品，直到可 apply）
---

批量生成实现前需要的制品（遵循依赖顺序），直到达到 apply-ready。

**输入**：`/opsx-ff [change-name]`

**步骤**
1. 选择 change（未提供时用 `openspec list --json` + AskUserQuestion）。
2. 读取状态：`openspec status --change "<name>" --json`。
3. 循环处理所有 `ready` 制品：
   - `openspec instructions <artifact-id> --change "<name>" --json`
   - 读取依赖、按模板创建、写入 outputPath
4. 每轮后刷新 status，直到 `applyRequires` 全部 `done`。
5. 输出最终状态与下一步 `/opsx-apply`。

**护栏**
- 仅创建制品，不做业务代码实现
- 严格按依赖顺序推进
- `context/rules` 不写入产物正文
