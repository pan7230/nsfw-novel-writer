# NSFW Novel Writer (Local) - 使用指南 v2.1

NSFW Novel Writer (Local) 是一个专为成人向小说创作设计的 WorkBuddy AI Agent 技能。**v2.1 核心变更：彻底移除 YAML 配置，直接对接 WorkBuddy 本地模型服务（OpenAI 兼容 API），加载技能即可使用。**

## 📦 目录结构

```
nsfw-novel-writer-local/
├── SKILL.md              # 技能说明文档（已集成到 WorkBuddy）
├── README.md             # 本使用指南 v2.1（零配置版）
├── icon.png              # 技能图标
├── scripts/              # 本地模型调用与可选自托管脚本
│   ├── generate.sh          # ★ 核心：调用 WorkBuddy 本地模型 API
│   ├── run_server.sh        # （可选）自建本地推理服务
│   ├── deploy_models.sh     # （可选）从 HF 镜像下载模型权重
│   ├── convert_models.sh    # （可选）转换为 GGUF 格式
│   └── convert_to_llamacpp.sh
└── references/           # 写作辅助参考（角色卡/强度档位/提示词库等）
```

## 🚀 快速开始（三步，零配置）

### 第一步：在 WorkBuddy 加载本地模型

通过你习惯的方式把无审查模型跑起来，并确认它对外提供 **OpenAI 兼容的 Chat Completions API**（WorkBuddy 本地模型服务、Ollama、llama.cpp、vLLM 等均可）。

### 第二步：（可选）指定端点

如果本地模型 API 不是默认地址，在 shell 中导出环境变量即可，**无需任何配置文件**：

```bash
export LOCAL_MODEL_ENDPOINT="http://localhost:8080/v1/chat/completions"
```

不设置则使用默认值 `http://localhost:11434/v1/chat/completions`。

### 第三步：加载技能并开始创作

在 WorkBuddy 的「专家中心」搜索并加载 **NSFW Novel Writer (Local)**，然后直接描述需求：

```
"帮我写一段两个角色在雨夜的咖啡馆相遇的场景，要有暧昧的张力。"
```

```
[模式：第一人称] [风格：细腻含蓄]
"我想写一段关于初恋重逢的故事，女主是林悦，男主是她高中时的同桌。"
```

## 🔌 本地模型如何被调用

技能通过 `scripts/generate.sh` 调用 WorkBuddy 本地模型服务：

- 读取环境变量 `LOCAL_MODEL_ENDPOINT`（默认 `http://localhost:11434/v1/chat/completions`）
- 兼容标准 OpenAI Chat Completions 请求体
- 你在 WorkBuddy 里选用哪个本地模型，技能就用哪个 —— **切换模型无需改任何代码**

生成流程：拼装提示词 → 调用本地模型 API 取回正文 → 应用 SANCTIS-Δ 架构层优化 → 执行敏感词规避检查 → 返回成品。

你也可以手动测试模型端点：

```bash
echo "写一段雨夜相遇的开场白" | bash scripts/generate.sh
```

## 🛠️ 可选：自建本地推理服务

如果你不想用 WorkBuddy 内置的本地模型服务，也可以用附带的脚本自己跑一个 OpenAI 兼容服务（这些脚本**不是使用本技能的必需步骤**）：

```bash
# 启动 llama.cpp / vLLM / Transformers 服务（具体见脚本内说明）
bash scripts/run_server.sh llama.cpp  path/to/model.gguf
bash scripts/run_server.sh vllm       MODEL_NAME
bash scripts/run_server.sh transformers
```

需要下载模型权重时（约 3GB 起），可用：

```bash
bash scripts/deploy_models.sh            # 走 hf-mirror 加速下载
```

## 🎯 使用 WorkBuddy 技能

1. 打开 WorkBuddy 左侧「专家中心」
2. 搜索 **NSFW Novel Writer (Local)** 并加载
3. 直接对话创作，随时切换模式/风格/NSFW 档位

### 模式与风格

```
[模式：第一人称] [风格：细腻含蓄] "..."
[模式：多视角]   [风格：直白热烈] "..."
[NSFW 档位：3] "把刚才那段改成更直接的描写。"
```

## 📊 NSFW 档位说明

| 档位 | 描述 | 适用场景 |
|------|------|----------|
| 0 | 完全 SFW，仅暗示 | 前期铺垫、日常对话 |
| 1 | 轻微亲密接触 | 牵手、拥抱、亲吻脸颊 |
| 2 | 明确的情感与肢体吸引 | 深吻、爱抚、裸露关键部位暗示 |
| 3 | 直接的 NSFW 描写 | 完整的亲密场景，详细的感官描述 |
| 4 | 极限强度 NSFW | 高度露骨的描写，适合成熟读者 |

## 🛡️ 敏感词规避机制

- **同义替换**：自动将高频敏感词映射到平台友好表达
- **句式重构**：调整直接描述为隐喻或侧面描写
- **强度分级**：根据 NSFW 档位（0-4）动态调整露骨程度
- **上下文感知**：区分医学、文学等合法使用场景

## 🐛 常见问题排查

### Q：调用本地模型失败 / 超时

**A:**
1. 确认本地模型服务已启动，且暴露的是 `/v1/chat/completions` 接口
2. 确认 `LOCAL_MODEL_ENDPOINT` 指向正确地址（默认 `http://localhost:11434/v1/chat/completions`）
3. 用 `curl` 手动探测：`curl -s $LOCAL_MODEL_ENDPOINT -H 'Content-Type: application/json' -d '{"model":"x","messages":[{"role":"user","content":"hi"}]}'`

### Q：输出质量不佳

**A:**
1. 在提示词中适当提高 temperature（0.7–0.9）
2. 选用质量更高的本地模型
3. 明确指定 NSFW 档位与风格

### Q：敏感词仍被平台过滤

**A:**
1. 降低 NSFW 档位（0–2）
2. 使用更含蓄的「细腻含蓄」风格
3. 不同平台敏感词库有差异，建议本地测试

## 📄 License

MIT License — See SKILL.md for details.

---

**Author**: WorkBuddy NSFW Novel Writer Team
**Version**: 2.1.0
**Last Updated**: November 2026
