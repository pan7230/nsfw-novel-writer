# 技能备忘：NSFW Novel Writer (Local) 双格式版

本目录保存同一份技能的**两份副本**，内容完全一致，仅以目录名区分，互不覆盖：

| 目录 | 面向 | 说明 |
|------|------|------|
| `nsfw-novel-writer-local.workbuddy/` | WorkBuddy | 用户级技能副本 |
| `nsfw-novel-writer-local.bionic/` | Bionic (LM Studio) | 按 Agent Skills 开放规范整理，可直接导入 |

> 原始技能（v2.1.0 零配置版）仍在 `~/.workbuddy/skills/nsfw-novel-writer-local/` 与 GitHub 仓库 `main` 分支，本目录**不修改、不覆盖**它。

## SKILL.md 格式说明（Bionic 兼容）

Bionic 使用 Anthropic 开放的 [Agent Skills 规范](https://agentskills.io)，`SKILL.md` 由两部分组成：

```
---
name: nsfw-novel-writer-local     # 必填，小写字母/数字/连字符
description: "..."               # 必填，描述做什么 + 何时使用
---

# 标题与 Markdown 正文（技能指令）
```

- **只有 `name` 和 `description` 必填**；其它字段会被 Bionic 忽略。
- `name` 仅允许小写字母、数字、连字符，最长 64 字符。
- `description` 最长 1024 字符；frontmatter 中不要出现尖括号 `<` `>`。
- 目录结构：技能文件夹根目录放 `SKILL.md`，可选 `scripts/`、`references/`、`assets/`。

本技能的 frontmatter 同时保留了 `display_name` / `description_zh` / `description_en` / `category` / `version` / `author` / `agent_created` 等字段，供 WorkBuddy 索引使用；Bionic 会忽略这些未知字段，因此**同一份文件可同时兼容两端**。

## 导入 Bionic 的方式

1. **直接拖入**：LM Studio Bionic → `Settings > Skills`，把 `nsfw-novel-writer-local.bionic/SKILL.md` 拖进去。
2. **从 URL 安装**：在 Bionic 中让它安装以下地址（或把该 URL 交给 `@Install Skill`）：
   ```
   https://raw.githubusercontent.com/pan7230/nsfw-novel-writer/skills/dual-format/nsfw-novel-writer-local.bionic/SKILL.md
   ```
3. **复用其它 Agent 的技能目录**：`Settings > Skills > Skills from other apps` 中启用对应目录。

导入后用 `@` 语法在 composer 中调用。注意：按规范 Bionic 主要读取 `SKILL.md` 本身，`scripts/` 与 `references/` 属可选辅助文件，如需使用请保留在本地工作区。

## 技能能力（v2.1.0 零配置版）

- 双模式：第一人称沉浸式描写 / 多视角切换与剧情推进
- 双风格：细腻含蓄 / 直白热烈
- 自动润色与平台敏感词规避
- 直连 WorkBuddy 本地模型（OpenAI 兼容 `/v1/chat/completions`），端点由 `LOCAL_MODEL_ENDPOINT` 指定，默认 `http://localhost:11434/v1/chat/completions`；**无需任何 YAML 配置**
- 不含任何模型权重，模型由用户自行下载加载

## 目录内文件（每个版本 14 个）

```
SKILL.md              # 技能入口（合规 frontmatter + 正文）
README.md             # 使用指南
icon.png              # 图标
.gitignore            # 排除模型权重
scripts/              # 5 个脚本：generate / deploy_models / convert_models / convert_to_llamacpp / run_server
references/           # 5 份写作指南：角色卡 / 强度档位 / 提示词库 / 导出格式 / 写作辅助
```

## 合规声明

本技能严格限定于成年人、虚构、双方自愿的情节创作；拒绝未成年人、非自愿、剥削及任何违法内容。请遵守所在平台与地区的法律法规。
