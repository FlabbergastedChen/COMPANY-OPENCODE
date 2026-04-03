---
description: 归档已完成的变更（实验性）
---

将指定 change 归档到 `openspec/changes/archive/YYYY-MM-DD-<name>`。

**输入**：`/opsx-archive [change-name]`

**步骤**
1. 选择 change（未提供时必须询问，不自动猜）。
2. 检查 artifact 完成度（`openspec status --json`）。
3. 检查 tasks 完成度（`tasks.md` 复选框统计）。
4. 若存在 delta specs，先做 sync 评估并让用户选择是否同步。
5. 执行归档：
```bash
mkdir -p openspec/changes/archive
mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>
```
6. 输出归档摘要与警告项。

**护栏**
- 可带警告归档，但必须先告知并确认
- 若目标归档目录已存在，报错并给处理选项
