# COMPANY-OPENCODE 使用说明

本文档覆盖从“拿到安装包”到“安装、使用、扩展、更新、卸载”的完整流程。

## 1. 拿到安装包后先做什么

1. 解压安装包到本地目录（示例）：

```bash
/data/cjr/COMPANY-OPENCODE
```

2. 进入项目根目录，确认关键文件存在：

```bash
cd /data/cjr/COMPANY-OPENCODE
ls bundle install
```

应至少看到：
- `bundle/`
- `install/install-company-opencode.sh`
- `install/upgrade-company-opencode.sh`
- `install/uninstall-company-opencode.sh`

## 2. 安装

注意：必须用 `bash` 执行，不要用 `sh`。

```bash
cd /data/cjr/COMPANY-OPENCODE
bash install/install-company-opencode.sh
```

安装完成后会生成：
- 运行包装命令：`opencode-company`
- 更新命令：`opencode-company-upgrade`
- 回滚命令：`opencode-company-rollback`
- 卸载命令：`opencode-company-uninstall`

并注入环境变量：
- `OPENCODE_CONFIG_DIR=~/.company-opencode/current`
- `PATH` 增加 `~/.local/bin`

## 3. 基础验证

```bash
opencode-company --version
readlink -f ~/.company-opencode/current
sed -n '1,120p' ~/.company-opencode/current/opencode.jsonc
```

`opencode.jsonc` 中应包含 `instructions` 配置。

## 4. 如何使用内置 Agent 和 Command

启动：

```bash
opencode-company
```

### 4.1 主要 Agent

- `speckit-orchestrator`
- `openspec-orchestrator`
- `superpowers-orchestrator`
- `superpowers-code-reviewer`（评审子代理）

### 4.2 主要命令

- Speckit：`/speckit-specify`、`/speckit-plan`、`/speckit-tasks`、`/speckit-implement`
- OpenSpec：`/openspec-propose`、`/openspec-apply`、`/openspec-verify`
- Superpowers：`/superpowers-brainstorm`、`/superpowers-write-plan`、`/superpowers-execute-plan`、`/superpowers-request-review`

示例：

```text
/superpowers-brainstorm 实现一个堆排序
/superpowers-write-plan 为堆排序生成任务计划
/superpowers-execute-plan
```

## 5. 用户如何注入自定义 md（instructions / commands / skills / agents）

推荐两种方式：项目级（推荐）和全局级。

### 5.1 项目级（推荐，不影响其他项目）

在你的业务项目根目录创建 `.opencode`：

```bash
mkdir -p .opencode/{instructions,commands,skills,agents}
```

#### A) 注入自定义 instructions（md）

1. 新建文件：

```bash
cat > .opencode/instructions/team-rules.md <<'EOF2'
# Team Rules
- 先写计划，再编码。
- 完成前必须给出验证证据。
EOF2
```

2. 在项目 `opencode.jsonc` 中声明：

```jsonc
{
  "instructions": [
    ".opencode/instructions/team-rules.md"
  ]
}
```

完整可复制示例（项目根目录）：

```bash
mkdir -p .opencode/instructions
cat > .opencode/instructions/review-rules.md <<'EOF2'
# Review Rules

## 必须遵守
1. 先指出风险再给风格建议。
2. 每条问题必须包含影响与修复方向。
3. 没有验证证据时，不能给“完成”结论。

## 输出格式
- Findings（按严重度）
- Open Questions
- Decision（Block / Needs Changes / Approve with Follow-ups）
EOF2

cat > opencode.jsonc <<'EOF2'
{
  "instructions": [
    ".opencode/instructions/review-rules.md"
  ]
}
EOF2
```

#### B) 注入自定义 command（md）

在 `.opencode/commands/` 下新增命令 md（含 frontmatter `description`）。

完整可复制示例（新增 `/my-quick-plan`）：

```bash
mkdir -p .opencode/commands
cat > .opencode/commands/my-quick-plan.md <<'EOF2'
---
description: "快速产出可执行计划（3-7步）。"
---

你正在执行命令 `/my-quick-plan`。

用户输入参数：`$ARGUMENTS`

执行要求：
1. 先明确目标、边界与验收标准。
2. 产出 3-7 个可执行步骤，每步都要可验证。
3. 若信息不足，先列出最小假设并标注风险。

输出要求：
- 计划步骤（编号）
- 每步验证方法
- 风险与后续动作
EOF2
```

#### C) 注入自定义 skill（SKILL.md）

目录结构示例：

```text
.opencode/skills/my-skill/SKILL.md
```

`SKILL.md` 必须有 frontmatter，至少包含 `name` 和 `description`，且 `name` 与目录名一致。

完整可复制示例（`my-risk-review`）：

```bash
mkdir -p .opencode/skills/my-risk-review
cat > .opencode/skills/my-risk-review/SKILL.md <<'EOF2'
---
name: my-risk-review
description: "风险优先的代码评审技能。"
---

## 作用
对代码变更做风险优先评审，优先发现阻断问题。

## 执行步骤
1. 读取变更范围与验收标准。
2. 按正确性、回归、安全、测试缺口做检查。
3. 以严重度输出问题和修复建议。

## 输出要求
- Findings（P0/P1/P2/P3）
- Open Questions
- Decision（Block / Needs Changes / Approve with Follow-ups）
EOF2
```

#### D) 注入自定义 agent（md）

在 `.opencode/agents/` 下新增 agent md（建议使用 frontmatter：`description`、`mode`、`permission`）。

完整可复制示例（`my-review-orchestrator`）：

```bash
mkdir -p .opencode/agents
cat > .opencode/agents/my-review-orchestrator.md <<'EOF2'
---
description: 自定义评审编排代理，负责组织审查输入和输出
mode: all
temperature: 0.1
permission:
  edit: deny
  bash: deny
  webfetch: ask
---

你是评审编排代理。

工作目标：
1. 收集评审所需上下文（需求、变更范围、验证证据）。
2. 指定评审重点（高风险路径、回归面、测试缺口）。
3. 输出统一格式结论。

输出格式：
1. Findings
2. Open Questions
3. Decision
EOF2
```

### 5.2 全局级（所有项目生效）

可放到：

```text
~/.config/opencode/instructions/
~/.config/opencode/commands/
~/.config/opencode/skills/
~/.config/opencode/agents/
```

然后在全局 `~/.config/opencode/opencode.jsonc` 配置 `instructions`。

完整可复制示例（全局配置）：

```bash
mkdir -p ~/.config/opencode/instructions
cat > ~/.config/opencode/instructions/global-rules.md <<'EOF2'
# Global Rules
1. 完成前必须有验证证据。
2. 先风险后风格。
EOF2

cat > ~/.config/opencode/opencode.jsonc <<'EOF2'
{
  "instructions": [
    "~/.config/opencode/instructions/global-rules.md"
  ]
}
EOF2
```

## 6. 更新

```bash
cd /data/cjr/COMPANY-OPENCODE
bash install/upgrade-company-opencode.sh
```

更新后建议验证：

```bash
readlink -f ~/.company-opencode/current
opencode-company --version
```

## 7. 卸载（不删除你解压的项目目录）

```bash
cd /data/cjr/COMPANY-OPENCODE
bash install/uninstall-company-opencode.sh
```

或：

```bash
opencode-company-uninstall
```

卸载会：
- 删除 `~/.company-opencode`
- 删除 `~/.local/bin/opencode-company*` 包装命令
- 删除 shell rc 中注入的 `company-opencode` 环境变量块

不会删除：
- 你解压出来的项目目录（例如 `/data/cjr/COMPANY-OPENCODE`）

## 8. 常见问题

### 8.1 为什么提示 `Skill "xxx" Unable to connect`？

优先检查：

```bash
env | grep -Ei 'proxy|http_proxy|https_proxy|all_proxy|no_proxy'
ls -ld ~/.company-opencode/current/skills ~/.config/opencode/skills
```

再执行一次安装/升级，确保最新 bundle 已生效：

```bash
bash install/install-company-opencode.sh
```

### 8.2 配置报错 `Unrecognized keys: workflow, qualityGates`

说明正在使用旧版 `opencode.jsonc`。执行升级脚本刷新当前包：

```bash
bash install/upgrade-company-opencode.sh
```
