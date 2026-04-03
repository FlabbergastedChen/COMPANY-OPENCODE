# AGENTS.md

## 关于 Spec Kit 与 Specify

**GitHub Spec Kit** 是一套用于 Spec-Driven Development（SDD，规格驱动开发）的完整工具集。该方法强调“先定义清晰规格，再进入实现”。工具集提供模板、脚本与工作流，帮助团队以结构化方式推进软件开发。

**Specify CLI** 是用于初始化 Spec Kit 项目的命令行入口。它会创建目录结构、模板文件以及 AI 代理集成配置，以支持规格驱动流程。

该工具集支持多种 AI 编码助手，使团队可在统一项目结构与实践下使用各自偏好的工具。

---

## 如何新增 Agent 支持

本节说明如何为 Specify CLI 新增 AI 代理或助手支持，用于将新工具接入规格驱动开发流程。

### 概览

Specify 通过在项目初始化时生成“代理专属命令文件与目录结构”来支持多代理。不同代理在以下方面有差异：

- **命令文件格式**（Markdown、TOML 等）
- **目录结构**（如 `.claude/commands/`、`.windsurf/workflows/`）
- **命令调用方式**（斜杠命令、CLI 工具等）
- **参数传递约定**（如 `$ARGUMENTS`、`{{args}}`）

### 当前支持的代理

| Agent | Directory | Format | CLI Tool | Description |
| --- | --- | --- | --- | --- |
| **Claude Code** | `.claude/commands/` | Markdown | `claude` | Anthropic 的 Claude Code CLI |
| **Gemini CLI** | `.gemini/commands/` | TOML | `gemini` | Google 的 Gemini CLI |
| **GitHub Copilot** | `.github/agents/` | Markdown | N/A（基于 IDE） | VS Code 中的 GitHub Copilot |
| **Cursor** | `.cursor/commands/` | Markdown | N/A（基于 IDE） | Cursor IDE（`--ai cursor-agent`） |
| **Qwen Code** | `.qwen/commands/` | Markdown | `qwen` | 阿里巴巴 Qwen Code CLI |
| **opencode** | `.opencode/command/` | Markdown | `opencode` | opencode CLI |
| **Codex CLI** | `.agents/skills/` | Markdown | `codex` | Codex CLI（`--ai codex --ai-skills`） |
| **Windsurf** | `.windsurf/workflows/` | Markdown | N/A（基于 IDE） | Windsurf IDE 工作流 |
| **Junie** | `.junie/commands/` | Markdown | `junie` | JetBrains 的 Junie |
| **Kilo Code** | `.kilocode/workflows/` | Markdown | N/A（基于 IDE） | Kilo Code IDE |
| **Auggie CLI** | `.augment/commands/` | Markdown | `auggie` | Auggie CLI |
| **Roo Code** | `.roo/commands/` | Markdown | N/A（基于 IDE） | Roo Code IDE |
| **CodeBuddy CLI** | `.codebuddy/commands/` | Markdown | `codebuddy` | CodeBuddy CLI |
| **Qoder CLI** | `.qoder/commands/` | Markdown | `qodercli` | Qoder CLI |
| **Kiro CLI** | `.kiro/prompts/` | Markdown | `kiro-cli` | Kiro CLI |
| **Amp** | `.agents/commands/` | Markdown | `amp` | Amp CLI |
| **SHAI** | `.shai/commands/` | Markdown | `shai` | SHAI CLI |
| **Tabnine CLI** | `.tabnine/agent/commands/` | TOML | `tabnine` | Tabnine CLI |
| **Kimi Code** | `.kimi/skills/` | Markdown | `kimi` | Kimi Code CLI（Moonshot AI） |
| **Pi Coding Agent** | `.pi/prompts/` | Markdown | `pi` | Pi 终端编码代理 |
| **iFlow CLI** | `.iflow/commands/` | Markdown | `iflow` | iFlow CLI（iflow-ai） |
| **Forge** | `.forge/commands/` | Markdown | `forge` | Forge CLI（forgecode.dev） |
| **IBM Bob** | `.bob/commands/` | Markdown | N/A（基于 IDE） | IBM Bob IDE |
| **Trae** | `.trae/rules/` | Markdown | N/A（基于 IDE） | Trae IDE |
| **Antigravity** | `.agent/commands/` | Markdown | N/A（基于 IDE） | Antigravity IDE（`--ai agy --ai-skills`） |
| **Mistral Vibe** | `.vibe/prompts/` | Markdown | `vibe` | Mistral Vibe CLI |
| **Generic** | 通过 `--ai-commands-dir` 由用户指定 | Markdown | N/A | 自定义代理 |

### 分步集成指南

（以下内容为原文结构的中文翻译，示例代码保持原样，便于直接使用。）

#### 1) 将新代理加入 AGENT_CONFIG

**重要**：字典 key 必须使用真实 CLI 工具名，而不是缩写别名。

在 `src/specify_cli/__init__.py` 的 `AGENT_CONFIG` 中新增配置（该结构是唯一事实来源）。

#### 2) 更新 CLI 帮助文本

在 `init()` 的 `--ai` 选项帮助文案中加入新代理。

#### 3) 更新 README

在 README 的 “Supported AI Agents” 部分加入新代理条目（名称、链接、支持级别与备注）。

#### 4) 更新发布打包脚本

修改 `.github/workflows/scripts/create-release-packages.sh`：

- 在 `ALL_AGENTS` 中加入新代理。
- 在 case 分支中补充目录与命令生成逻辑。

#### 5) 更新 GitHub 发布脚本

在 `.github/workflows/scripts/create-github-release.sh` 中加入新代理产物包。

#### 6) 更新 Agent Context 脚本

分别更新：

- `scripts/bash/update-agent-context.sh`
- `scripts/powershell/update-agent-context.ps1`

确保新代理路径与默认分支处理逻辑都被纳入。

#### 7) CLI 工具检查（可选）

若新代理依赖 CLI，可在 `check()` 与 `init` 校验流程中补充检查。若已使用 `AGENT_CONFIG.requires_cli` 自动检查机制，可无需额外改动。

## 重要设计决策

（保留：请继续遵循原文中的设计原则与命名约束，特别是“配置 key 与真实 CLI 名称一致”的原则。）
