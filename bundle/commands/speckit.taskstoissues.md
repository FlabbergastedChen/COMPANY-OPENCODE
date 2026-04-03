---
description: 将现有任务转换为可执行、按依赖有序的 GitHub Issue。
tools: ['github/github-mcp-server/issue_write']
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入非空，你**必须**在执行前纳入考虑。

## 流程

1. 在仓库根目录运行 `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks`，解析 `FEATURE_DIR` 与 `AVAILABLE_DOCS`，并使用绝对路径。
1. 从脚本结果中提取 **tasks** 文件路径。
1. 获取 Git 远程地址：

```bash
git config --get remote.origin.url
```

> [!CAUTION]
> 仅当远程地址是 GitHub URL 时，才继续后续步骤。

1. 遍历任务清单，并使用 GitHub MCP 为对应仓库创建 issue。

> [!CAUTION]
> 绝对不要在与当前 remote 不匹配的仓库中创建 issue。
