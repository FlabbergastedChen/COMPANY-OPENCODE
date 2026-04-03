---
description: 继续一个变更（一次只创建下一个可用制品）
---

按依赖顺序继续当前 change，一次只创建一个 `ready` 制品。

**输入**：`/opsx-continue [change-name]`

**步骤**

1. **选择 change**
- 若未提供名称：运行 `openspec list --json`，使用 **AskUserQuestion** 让用户选择。
- 展示最近修改的 3-4 个 change（名称、schema、状态、最近更新时间）。
- 不自动猜测。

2. **读取当前状态**
```bash
openspec status --change "<name>" --json
```
- 关注：`schemaName`、`artifacts`、`isComplete`。

3. **按状态处理**
- 若 `isComplete: true`：提示已完成，可 `/opsx-apply` 或 `/opsx-archive`。
- 若有 `ready` 制品：取第一个，拉取指引并创建该制品：
```bash
openspec instructions <artifact-id> --change "<name>" --json
```
- 若全是 blocked：展示状态并提示检查依赖。

4. **创建该制品**
- 读取依赖制品文件。
- 按 `template` 填写内容。
- `context` / `rules` 仅作为写作约束，不写入文件。
- 写入 `outputPath`。

5. **回显进度**
```bash
openspec status --change "<name>"
```

**输出**
- 本次创建了哪个 artifact
- 当前进度 N/M
- 新解锁了哪些 artifact
- 提示：继续运行 `/opsx-continue`

**护栏**
- 每次只创建一个 artifact
- 不跳过依赖、不越序
- 上下文不清则先询问
