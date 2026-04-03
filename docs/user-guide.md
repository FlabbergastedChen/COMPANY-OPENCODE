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
- `install/install-company-opencode.ps1`
- `install/upgrade-company-opencode.sh`
- `install/uninstall-company-opencode.sh`
- `install/uninstall-company-opencode.ps1`

## 2. 安装

### 2.1 Linux / macOS

注意：必须用 `bash` 执行，不要用 `sh`。

```bash
cd /data/cjr/COMPANY-OPENCODE
bash install/install-company-opencode.sh
```

### 2.2 Windows（PowerShell）

```powershell
cd C:\path\to\COMPANY-OPENCODE
powershell -ExecutionPolicy Bypass -File .\install\install-company-opencode.ps1
```

说明：
- Windows 安装脚本会把 `OPENCODE_CONFIG_DIR` 写入用户环境变量。
- 若本机 `npm -g` 有权限限制，脚本会自动改用用户目录前缀安装（`%USERPROFILE%\.company-opencode\npm-global`），避免管理员权限报错。

Linux / macOS 与 Windows 安装完成后都会生成：
- 运行包装命令：`opencode-company`
- 更新命令：`opencode-company-upgrade`
- 回滚命令：`opencode-company-rollback`
- 卸载命令：`opencode-company-uninstall`

并注入环境变量：
- `OPENCODE_CONFIG_DIR=~/.company-opencode/current`
- `PATH` 增加 `~/.local/bin`

Windows 安装完成后会：
- 写入用户环境变量 `OPENCODE_CONFIG_DIR=%USERPROFILE%\.company-opencode\current`
- 在用户 `PATH` 中加入 `%USERPROFILE%\.company-opencode\npm-global`（用于 `opencode` 命令）

## 3. 基础验证

### 3.1 Linux / macOS

```bash
opencode-company --version
readlink -f ~/.company-opencode/current
sed -n '1,120p' ~/.company-opencode/current/opencode.jsonc
```

### 3.2 Windows（PowerShell）

```powershell
opencode --version
Get-Item "$env:USERPROFILE\.company-opencode\current"
Get-Content "$env:USERPROFILE\.company-opencode\current\opencode.jsonc" -TotalCount 120
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
- `code-reviewer`（代码评审代理）

### 4.2 内置命令总览（按当前项目）

- Speckit：`/speckit-specify`、`/speckit-clarify`、`/speckit-plan`、`/speckit-tasks`、`/speckit-implement`、`/speckit-checklist`、`/speckit-analyze`、`/speckit-constitution`、`/speckit-taskstoissues`
- OPSX：`/opsx-onboard`、`/opsx-explore`、`/opsx-propose`、`/opsx-apply`、`/opsx-verify`、`/opsx-sync`、`/opsx-new`、`/opsx-continue`、`/opsx-ff`、`/opsx-archive`、`/opsx-bulk-archive`
- Superpowers：`/superpowers-brainstorm`、`/superpowers-write-plan`、`/superpowers-execute-plan`

### 4.3 推荐使用流程

1. Speckit（需求到实现）  
   `/speckit-specify -> /speckit-clarify -> /speckit-plan -> /speckit-tasks -> /speckit-implement`
2. OPSX（变更编排）  
   `/opsx-explore -> /opsx-propose -> /opsx-apply -> /opsx-verify -> /opsx-archive`
3. Superpowers（快速方案与执行）  
   `/superpowers-brainstorm -> /superpowers-write-plan -> /superpowers-execute-plan`

### 4.4 可复制示例

Speckit 示例：

```text
/speckit-specify 设计一个支持重试和幂等的支付回调模块
/speckit-clarify
/speckit-plan
/speckit-tasks
/speckit-implement
```

OPSX 示例：

```text
/opsx-explore 对现有登录流程做风险扫描并给出改造建议
/opsx-propose
/opsx-apply
/opsx-verify
/opsx-archive
```

Superpowers 示例：

```text
/superpowers-brainstorm 实现一个高可读性的堆排序教学版本
/superpowers-write-plan 为堆排序生成可执行任务计划
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

### 5.3 全局本地模型配置（按你的当前配置方式）

你的机器当前使用的是全局配置文件：

```text
~/.config/opencode/opencode.json
```

可按下面方式修改（OpenAI-compatible 本地网关）：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "minimax": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Minimax Local",
      "options": {
        "baseURL": "http://<你的地址>:<端口>/v1",
        "apiKey": "<你的密钥>"
      },
      "models": {
        "minimax25": {
          "name": "Minimax 25"
        }
      }
    }
  }
}
```

修改步骤（PowerShell / bash 都适用）：

1. 编辑文件 `~/.config/opencode/opencode.json`。
2. 只替换 `options.baseURL`、`options.apiKey`，以及需要的模型别名（如 `models.minimax25`）。
3. 保存后重开终端，或重启 opencode 会话使配置生效。

注意：
- `apiKey` 属于敏感信息，不要提交到 Git 仓库。
- 如果你同时配置了多个 provider，调用时要确保选择了对应模型别名。

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

### 7.1 Linux / macOS

```bash
cd /data/cjr/COMPANY-OPENCODE
bash install/uninstall-company-opencode.sh
```

或：

```bash
opencode-company-uninstall
```

### 7.2 Windows（PowerShell）

```powershell
cd C:\path\to\COMPANY-OPENCODE
powershell -ExecutionPolicy Bypass -File .\install\uninstall-company-opencode.ps1
```

卸载会：
- Linux / macOS：删除 `~/.company-opencode`、`~/.local/bin/opencode-company*` 包装命令、shell rc 中注入的 `company-opencode` 环境变量块
- Windows：删除 `%USERPROFILE%\.company-opencode`，并清理用户环境变量中的 `OPENCODE_CONFIG_DIR` 与 `%USERPROFILE%\.company-opencode\npm-global` 路径

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

### 8.3 Windows 安装报 `permission error`

常见原因是 `npm install -g` 需要管理员权限。新版 `install-company-opencode.ps1` 已默认使用用户级 npm prefix 规避此问题。若仍失败，检查：

```powershell
npm config get prefix --location=user
Test-Path "$env:USERPROFILE\.company-opencode\npm-global"
```

然后重新执行安装脚本：

```powershell
powershell -ExecutionPolicy Bypass -File .\install\install-company-opencode.ps1
```
