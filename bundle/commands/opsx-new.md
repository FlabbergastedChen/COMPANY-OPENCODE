---
description: 创建新变更（只创建 change 与首个制品指引，不直接生成全部制品）
---

创建一个新的 OpenSpec change，并展示首个可创建制品的模板与指引。

**输入**：`/opsx-new` 后可选传入变更名（kebab-case），或需求描述。

**步骤**

1. **若无输入，先询问要做什么**
- 使用 **AskUserQuestion**（开放问题）询问用户要构建或修复什么。
- 从描述中推导 kebab-case 名称（如 `add user auth` → `add-user-auth`）。
- 在明确目标前不要继续。

2. **确定 workflow schema**
- 默认使用默认 schema（不传 `--schema`）。
- 仅当用户明确要求某个 schema 时才使用 `--schema <name>`。
- 若用户问“有哪些 workflow/schema”，先运行 `openspec schemas --json` 再让其选择。

3. **创建 change 目录**
```bash
openspec new change "<name>"
```
（仅在指定 schema 时追加 `--schema <name>`）

4. **查看制品状态**
```bash
openspec status --change "<name>"
```

5. **获取首个 ready 制品指引**
- 从 status 找到首个 `ready` 的 artifact。
```bash
openspec instructions <first-artifact-id> --change "<name>"
```

6. **停止并等待用户指令**
- 本命令只到“展示首个制品模板”为止。

**输出**
- change 名与目录
- 使用中的 schema 与制品顺序
- 当前进度（0/N）
- 首个制品模板
- 提示：`可运行 /opsx-continue 继续创建下一个制品`

**护栏**
- 不创建任何制品内容（仅展示模板）
- 不越过首个制品模板阶段
- 名称不合法时要求修正
- 若同名 change 已存在，建议使用 `/opsx-continue`
