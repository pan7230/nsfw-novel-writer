---
name: nsfw-novel-writer-local
description: "成人向（18+）虚构小说创作引擎：支持第一人称沉浸式描写与多视角剧情推进，提供细腻含蓄/直白热烈双风格及自动润色、敏感词规避。Use when writing adult fictional romance or erotica, building character cards, world settings or chapter outlines, or switching narrative perspective and style. 直接对接 WorkBuddy 本地模型（OpenAI 兼容 API），无需配置文件，加载即用。"
display_name: "NSFW Novel Writer (Local)"
display_name_en: "NSFW Novel Writer (Local)"
description_zh: "本地模型版成人向（18+）虚构小说创作引擎。支持第一人称沉浸式描写与多视角剧情推进，提供细腻含蓄与直白热烈双风格及敏感词规避。直接对接 WorkBuddy 本地模型服务（OpenAI 兼容 API），无需配置 YAML，加载即用。"
description_en: "Local-model NSFW Novel Writer engine for 18+ fictional writing. Supports first-person immersion and multi-perspective progression, with dual style preferences (subtle/atmospheric vs direct/sensual) and auto-sensitive-word avoidance. Talks to WorkBuddy's local model service (OpenAI-compatible API) directly — no YAML config, load-and-use."
category: "写作创作"
version: "2.1.0"
author: "pan7230"
agent_created: true
---

# NSFW Novel Writer (Local)

NSFW Novel Writer (Local) 是一个专为成人向小说创作设计的 AI Agent 技能，支持第一人称沉浸式描写和多视角切换的剧情推进。该技能整合了 Velvet Ascent、SANCTIS-Δ 等多个优秀 NSFW 写作框架的核心特性，提供结构化的创作流程和智能的敏感词规避机制。

**核心差异（v2.1）**：彻底移除 `model_config.yaml` 配置文件。模型直接复用你在 WorkBuddy 中已加载的**本地模型服务**（OpenAI 兼容 `/v1/chat/completions` API）。你只需在 WorkBuddy 里把无审查模型加载好、暴露出本地 API 端点，加载本技能后即可直接开始创作，无需任何额外配置。

## ✨ 核心特性

- **双模式创作系统**
  - 第一人称沉浸式描写：适合情感与感官细节的深度刻画
  - 多视角切换与剧情推进：适合长篇连载的叙事结构

- **双风格偏好选择**
  - 细腻含蓄：侧重氛围营造与心理描写
  - 直白热烈：侧重动作场面与感官刺激

- **智能敏感词规避**
  - 自动识别并替换平台敏感词汇
  - 保持成人向张力的同时确保内容安全

- **直连 WorkBuddy 本地模型（零配置）**
  - 复用 WorkBuddy 已加载的本地模型服务（OpenAI 兼容 API）
  - 端点通过环境变量 `LOCAL_MODEL_ENDPOINT` 指定，默认为 `http://localhost:11434/v1/chat/completions`
  - 不绑定任何具体权重文件，不写死模型路径

- **结构化创作流程**
  - 角色卡与世界观设定
  - 剧情大纲与章节蓝图
  - 草稿生成、审稿修稿闭环

## 🚀 使用方式（零配置）

### 前置条件（一次性）

1. **准备本地模型**：通过你习惯的方式（WorkBuddy 本地模型加载、Ollama、llama.cpp、vLLM 等）把无审查模型跑起来，并确认它对外提供 **OpenAI 兼容的 Chat Completions API**。
2. **（可选）设置端点**：如果端点不是默认地址，在 shell 中导出环境变量即可，无需任何配置文件：
   ```bash
   export LOCAL_MODEL_ENDPOINT="http://localhost:8080/v1/chat/completions"
   ```
   不设置则使用默认值 `http://localhost:11434/v1/chat/completions`。

### 开始创作

直接在 WorkBuddy 中加载本技能，然后像下面这样描述需求即可：

```
"帮我写一段两个角色在雨夜的咖啡馆相遇的场景，要有暧昧的张力。"
```

```
[模式：第一人称] [风格：细腻含蓄]
"我想写一段关于初恋重逢的故事，女主是林悦，男主是她高中时的同桌。"
```

```
[模式：多视角] [风格：直白热烈]
"创作一个都市爱情故事，需要切换男女主角的视角来推进剧情。"
```

### 调整风格与模式

在对话中随时切换：

```
[切换到直白热烈风格] "现在把刚才那段改成更直接的描写。"
```

## 🔌 本地模型集成

技能通过 `scripts/generate.sh` 调用 WorkBuddy 本地模型服务，无需任何 YAML 配置：

- 读取环境变量 `LOCAL_MODEL_ENDPOINT`（默认 `http://localhost:11434/v1/chat/completions`）
- 兼容标准 OpenAI Chat Completions 请求体（`model` / `messages` / `temperature` / `max_tokens` 等）
- 你在 WorkBuddy 里选用哪个本地模型，技能就用哪个 —— 切换模型无需改代码

技能生成流程：根据模板拼装提示词 → 调用本地模型 API 取回正文 → 应用 SANCTIS-Δ 架构层优化 → 执行敏感词规避检查 → 返回成品。

> 如果你希望自己独立跑推理服务（不走 WorkBuddy 本地模型），`scripts/` 下仍保留了 `run_server.sh` / `convert_models.sh` 等可选脚本，但**已不再是使用本技能的必需步骤**。

## 🎯 核心机制

### 1. 模式系统

| 模式 | 适用场景 | 特点 |
|------|----------|------|
| 第一人称 | 情感细腻、心理描写丰富的短篇或章节 | 沉浸感强，视角固定，适合深度刻画人物内心 |
| 多视角 | 长篇连载、多人物关系网 | 剧情推进快，可多角度展现故事全貌 |

### 2. 风格系统

| 风格 | 描写侧重 | 语言特点 |
|------|----------|----------|
| 细腻含蓄 | 氛围、心理活动、隐喻 | 留白多，意境美，适合文艺向作品 |
| 直白热烈 | 动作、感官刺激、直接对话 | 节奏快，张力足，适合商业向作品 |

### 3. SANCTIS-Δ 架构层（智能稳定模块）

整合了 SANCTIS-Δ 的七大核心层，确保高强度场景下的输出稳定性：

- **LUX（感官清晰度）**：分离感官细节与叙事流，防止信息过载
- **CRESCEN（节奏编排器）**：管理情感与感官的起伏节奏
- **KAIROS（情感逻辑引擎）**：保持角色反应的真实性与连贯性
- **AEGIS（边界完整性模块）**：确保 consent-aware 的安全框架
- **SOMNIA（沉浸锚点）**：抑制跳出第四面墙的元评论
- **ATARAXIA（漂移抑制格）**：防止角色声音侵蚀与叙事偏离
- **EROS-LOGOS（整合层）**：平衡激情与叙事逻辑

### 4. 敏感词规避机制

内置动态敏感词库，自动执行以下策略：

- **同义替换**：将高频敏感词映射到平台友好的替代表达
- **句式重构**：调整直接描述为隐喻或侧面描写
- **强度分级**：根据 NSFW 档位（0-4）动态调整露骨程度
- **上下文感知**：区分医学、文学等合法使用场景

## 📁 工作区结构

技能维护以下文件以追踪创作状态（位于当前工作区）：

```
/workspace/
├── characters.md          # 角色档案（姓名、性格、欲望、XP）
├── world.md               # 世界观设定
├── outline.md             # 剧情大纲
├── blueprint.md           # 章节蓝图
├── draft/                 # 草稿文件（按章节）
│   ├── chapter_01.md
│   └── chapter_02.md
├── review/                # 审稿记录
│   └── review_chapter_01.md
└── revised/               # 修稿文件
    └── revised_chapter_01.md
```

## 🔄 创作流程示例

### 第一阶段：设定（用户输入）

```
[模式：多视角] [风格：细腻含蓄]

世界观：近未来赛博朋克都市，阶级分化严重
主角 A（女主）：26 岁，底层数据工，渴望逃离贫民窟
主角 B（男主）：32 岁，上层企业高管，厌倦虚伪的上流社会
关系状态：初次相遇，互相吸引但各有顾虑

剧情目标：通过一次意外让两人产生交集，建立初步情感连接
```

### 第二阶段：大纲生成（技能自动处理）

技能会基于用户输入生成剧情大纲，包含：
- 相遇场景设计（地点、时间、触发事件）
- 情感升温节点规划
- 关键冲突与转折预测

### 第三阶段：章节蓝图（技能生成）

```
第 1-3 章：铺垫与相遇
  - 介绍女主的生活困境
  - 展现男主的上层生活空虚感
  - 雨夜咖啡馆的初次邂逅

第 4-8 章：吸引与试探
  - 线上聊天的暧昧升温
  - 线下见面的紧张与期待
  - 第一次肢体接触

第 9-15 章：关系确立与深化
  - 情感突破的关键场景
  - 多视角切换展现双方心理变化
  - NSFW 张力逐步释放（档位 2-3）

第 16-20 章：冲突与解决
  - 外部阻力（阶级、家人反对）
  - 内部矛盾（信任危机）
  - 最终和解与承诺
```

### 第四阶段：草稿生成（技能执行）

用户确认蓝图后，技能开始逐章生成草稿。每章生成时会：
1. 读取相关角色档案和世界观设定
2. 根据当前章节目标生成提示词
3. 调用 WorkBuddy 本地模型 API 进行推理（见「本地模型集成」）
4. 应用 SANCTIS-Δ 架构层优化输出
5. 执行敏感词规避检查

### 第五阶段：审稿与修稿（可选）

用户可对草稿进行审阅，技能会生成审稿报告，包含：
- 情感节奏分析
- NSFW 强度评估
- 敏感词使用统计
- 改进建议

用户可基于审稿报告要求修改，技能会生成修订版本。

