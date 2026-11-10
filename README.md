# NSFW Novel Writer - 部署与使用指南

NSFW Novel Writer 是一个专为成人向小说创作设计的 WorkBuddy AI Agent 技能。本指南将帮助你完成模型的部署、配置和使用。

## 📦 目录结构

```
nsfw-novel-writer/
├── SKILL.md              # 技能说明文档（已集成到 WorkBuddy）
├── README.md             # 本部署指南
└── scripts/              # 部署脚本
    ├── deploy_models.sh      # 从 GitHub/HF下载模型
    ├── convert_models.sh     # 转换为 GGUF 格式
    ├── convert_to_llamacpp.sh# 专用 llama.cpp 转换脚本
    └── run_server.sh         # 启动推理服务器
```

## 🚀 快速开始

### 第一步：安装依赖

#### 1. 安装 GitHub 加速器（必需）

由于模型托管在 GitHub 上，需要先安装 GitHub 加速器技能：

```bash
# 在 WorkBuddy 中搜索并安装 "GitHub 加速器"
npx skills add github-accelerator
```

#### 2. 安装 Python（如果使用 Transformers）

```bash
# macOS
brew install python

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install python3 python3-pip

# Windows
# 从 https://www.python.org/downloads/ 下载并安装
```

#### 3. 安装 Python 依赖（Transformers 方式）

```bash
pip install flask transformers torch
```

### 第二步：部署模型

#### 方案 A：使用 deploy_models.sh（推荐）

```bash
cd /Users/pangu/WorkBuddy/2026-11-10-08-43-05/.workbuddy/skills/nsfw-novel-writer/scripts

# 部署两个模型（UnfilteredAI/NSFW-3B + OPT-125M）
./deploy_models.sh

# 或只部署单个模型
./deploy_models.sh UnfilteredAI/NSFW-3B

# 或只部署 OPT-125M
./deploy_models.sh OPT-125M
```

#### 方案 B：手动下载（如果 GitHub 不可用）

从 Hugging Face 镜像站下载（推荐 hf-mirror.com，速度更快）：

```bash
# UnfilteredAI/NSFW-3B (~3GB)

# 设置环境变量使用 hf-mirror（国内推荐）
export HF_ENDPOINT=https://hf-mirror.com

cd /Users/pangu/WorkBuddy/2026-11-10-08-43-05/.workbuddy/models/nsfw-novel-writer

# 使用 huggingface_hub snapshot_download（推荐）
pip install huggingface_hub
python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='UnfilteredAI/NSFW-3B', local_dir='.')"

# 或使用 huggingface-cli
huggingface-cli download UnfilteredAI/NSFW-3B --local-dir .

# 创建 meta.json
cat > UnfilteredAI/NSFW-3B/meta.json << EOF
{
    "name": "UnfilteredAI/NSFW-3B",
    "type": "transformers",
    "parameters": {
        "count": 3000000000,
        "unit": "parameters"
    },
    "files": {
        "model.safetensors.index.json": "model.safetensors.index.json",
        "tokenizer.json": "tokenizer.json"
    },
    "description": "UnfilteredAI NSFW-3B model for WorkBuddy",
    "license": "MIT"
}
EOF

# 注意：由于模型较大（约 3GB），建议使用专业的下载工具如 aria2c、IDM 或 FDM 进行多线程下载。
```

### 第三步：启动服务器

#### 方式 1：Transformers Flask API（推荐新手）

```bash
cd /Users/pangu/WorkBuddy/2026-11-10-08-43-05/.workbuddy/skills/nsfw-novel-writer/scripts

# 启动服务器（默认使用 UnfilteredAI/NSFW-3B）
./run_server.sh transformers

# 指定模型
./run_server.sh UnfilteredAI/NSFW-3B transformers

# 访问 http://localhost:5000
```

#### 方式 2：llama.cpp（推荐，资源占用少）

首先转换模型格式：

```bash
cd /Users/pangu/WorkBuddy/2026-11-10-08-43-05/.workbuddy/skills/nsfw-novel-writer/scripts

# 使用通用转换脚本
./convert_models.sh llama.cpp

# 或使用专用脚本（只转换 NSFW-3B）
./convert_to_llamacpp.sh
```

然后启动服务器：

```bash
# 启动 llama.cpp 服务器
./run_server.sh llama.cpp UnfilteredAI/NSFW-3B/nsfw-3b-q4_k_m.gguf

# 访问 http://localhost:8080/v1/chat/completions
```

#### 方式 3：vLLM（高性能，需要更多资源）

```bash
cd /Users/pangu/WorkBuddy/2026-11-10-08-43-05/.workbuddy/skills/nsfw-novel-writer/scripts

# 安装 vLLM（如果还没安装）
pip install vllm

# 启动服务器
./run_server.sh vllm UnfilteredAI/NSFW-3B

# 访问 http://localhost:8000/v1/chat/completions
```

## 🎯 使用 WorkBuddy 技能

### 1. 加载技能

在 WorkBuddy 中：
- 打开左侧菜单的"专家中心"
- 搜索 "NSFW Novel Writer"
- 点击加载

### 2. 基础对话模式

直接描述你的创作需求：

```
"帮我写一段两个角色在雨夜的咖啡馆相遇的场景，要有暧昧的张力。"
```

### 3. 第一人称沉浸式模式

```
[模式：第一人称] [风格：细腻含蓄]
"我想写一段关于初恋重逢的故事，女主是林悦，男主是她高中时的同桌。"
```

### 4. 多视角切换模式

```
[模式：多视角] [风格：直白热烈]
"创作一个都市爱情故事，需要切换男女主角的视角来推进剧情。"
```

### 5. 调整 NSFW 强度

```
[NSFW 档位：3] "现在把刚才那段改成更直接的描写。"
```

## 📊 已部署模型

当前工作区已部署以下模型：

| 模型 | 大小 | 推荐场景 | RAM 需求 |
|------|------|----------|----------|
| UnfilteredAI/NSFW-3B | ~3GB | 高质量 NSFW 小说生成 | 8GB+ |
| OPT-125M | ~125MB | 轻量级快速构思 | 2GB+ |
| nsfw-3b-q4_k_m.gguf | ~1.5GB | llama.cpp 最佳平衡点 | 6GB+ |
| nsfw-3b-q8_0.gguf | ~3.2GB | 最高质量（如果内存充足） | 16GB+ |

## 🛡️ 敏感词规避机制

技能内置了智能敏感词规避系统：

- **同义替换**：自动将高频敏感词映射到平台友好表达
- **句式重构**：调整直接描述为隐喻或侧面描写
- **强度分级**：根据 NSFW 档位（0-4）动态调整露骨程度
- **上下文感知**：区分医学、文学等合法使用场景

## 📝 提示词模板示例

### 第一人称沉浸模板

```
[模式：第一人称] [风格：细腻含蓄]

角色设定：
- 我（林悦，26 岁，数据工程师）
- 对方（陈默，30 岁，自由摄影师）

当前场景：雨夜的咖啡馆
情感状态：紧张、期待、些许不安

请从"我"的视角，以第一人称沉浸式的方式描写这个场景。
重点刻画：
1. 我的感官体验（雨声、咖啡香、对方的气息）
2. 我的内心活动和情绪变化
3. 细腻含蓄的风格表达

NSFW 强度档位：2（前期暧昧阶段）
```

### 多视角切换模板

```
[模式：多视角] [风格：直白热烈]

场景标题：雨夜邂逅
时间：周五晚上 8 点
地点：街角咖啡馆

视角 A（女主·林悦）:
- 性格：独立、敏感、渴望被理解
- 当前情感：紧张又期待

视角 B（男主·陈默）:
- 性格：随性、直接、有点痞气
- 当前情感：被吸引，想接近

请分别以林悦和陈默的视角，交替描写这个相遇的场景。
每个视角约 300 字。

NSFW 强度档位：2（初次吸引，肢体接触暗示）
```

## 🔧 进阶配置

### 自定义模型路径

在 `model_config.yaml` 中指定你的本地模型：

```yaml
current_model: "/path/to/your/custom-model"
available_models:
  - name: "UnfilteredAI/NSFW-3B"
    size_gb: 3
```

### 调整推理参数

```yaml
generation_params:
  max_new_tokens: 512      # 生成 token 数
  temperature: 0.85        # 温度（越高越有创意）
  top_p: 0.9              # nucleus sampling
  repetition_penalty: 1.1  # 重复惩罚
```

### SANCTIS-Δ 架构激活

当需要高强度场景时：

```
[激活 SANCTIS-Δ] "接下来这段需要更强烈的感官描写，保持角色性格不崩坏。"
```

## 🐛 常见问题排查

### Q: 模型下载失败

**A:** 
1. 确保已安装 GitHub 加速器技能
2. 检查磁盘空间（至少需要 5GB）
3. 尝试使用 Hugging Face 镜像下载

### Q: 服务器启动失败（CUDA out of memory）

**A:**
1. 切换到更小的模型（OPT-125M）
2. 使用量化版本（Q4_K_M、Q4_0）
3. 关闭其他占用 GPU 的程序

### Q: 输出质量不佳

**A:**
1. 提高 temperature（0.7-0.9）
2. 降低 top_p（0.85-0.95）
3. 增加 max_new_tokens

### Q: 敏感词仍然被平台过滤

**A:**
1. 降低 NSFW 档位（0-2）
2. 使用更含蓄的描写风格
3. 检查技能日志中的规避记录

## 📖 参考资源

- [UnfilteredAI/NSFW-3B on Hugging Face](https://huggingface.co/UnfilteredAI/NSFW-3B)
- [llama.cpp 文档](https://github.com/ggerganov/llama.cpp)
- [SANCTIS-Δ 架构说明](http://github.org/Umbraflamma/SANCTIS-Delta)
- [Velvet Ascent Skill](https://github.com/ruijayfeng/velvet-ascent-skill)

## 📄 License

MIT License - See SKILL.md for details.

---

**Author**: WorkBuddy NSFW Novel Writer Team  
**Version**: 1.0.0  
**Last Updated**: November 2026
