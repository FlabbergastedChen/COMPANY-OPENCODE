---
description: 一步提议新变更并生成实现前关键制品
---

创建 change，并按依赖顺序自动生成实现前关键制品（通常含 proposal/specs/design/tasks）。

**输入**：`/opsx-propose <change-name 或需求描述>`

**步骤**
1. 若输入不清，使用 **AskUserQuestion** 澄清目标。
2. 创建 change：
```bash
openspec new change "<name>"
```
3. 获取构建顺序：
```bash
openspec status --change "<name>" --json
```
4. 按依赖顺序创建 `ready` 制品，直到 `applyRequires` 全部完成：
```bash
openspec instructions <artifact-id> --change "<name>" --json
```
5. 显示最终状态并提示 `/opsx-apply`。

**输出**
- 变更目录
- 已创建制品列表
- 当前状态：可进入实现

**护栏**
- `context/rules` 仅作约束，不应写入文件正文
- 同名 change 已存在时先询问继续还是新建
