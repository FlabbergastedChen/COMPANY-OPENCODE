---
name: using-git-worktrees
description: "使用 git worktree 管理并行分支工作区，减少切换与冲突。"
---

# 使用 Git Worktree

## 适用场景
- 多任务并行开发
- 需要在不同分支间快速切换

## 基本流程
1. 创建 worktree 并关联分支
2. 在对应目录独立开发
3. 完成后提交并清理 worktree

## 护栏
- 保持分支职责单一
- 避免跨 worktree 误操作
