---
description: 将 change 的 delta specs 同步到主 specs
---

把 `openspec/changes/<name>/specs` 的增量规范同步到 `openspec/specs` 主规范。

**输入**：`/opsx-sync [change-name]`

**步骤**
1. 选择 change（仅展示有 delta specs 的 change）。
2. 识别 delta spec 中的：ADDED / MODIFIED / REMOVED / RENAMED。
3. 对每个 capability 执行智能合并：
- ADDED：新增需求（若已存在则按隐式修改处理）
- MODIFIED：局部更新并保留未提及内容
- REMOVED：删除需求块
- RENAMED：按 FROM/TO 重命名
4. capability 不存在时创建主 spec 文件。
5. 输出同步摘要。

**护栏**
- 先读 delta 再读主 spec
- 合并应幂等（重复执行结果一致）
