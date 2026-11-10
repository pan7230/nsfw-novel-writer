#!/bin/bash
#
# NSFW Novel Writer (Local) - 本地模型调用脚本
#
# 直接对接 WorkBuddy 本地模型服务（OpenAI 兼容 /v1/chat/completions API）。
# 无需任何 YAML 配置：端点通过环境变量 LOCAL_MODEL_ENDPOINT 指定，
# 未设置时使用默认值 http://localhost:11434/v1/chat/completions
#
# 用法:
#   echo "你的写作提示词" | bash generate.sh [system_prompt] [temperature] [max_tokens]
#   bash generate.sh "用户提示词" "系统提示词" 0.85 1024
#
# 依赖: curl, python3

set -euo pipefail

ENDPOINT="${LOCAL_MODEL_ENDPOINT:-http://localhost:11434/v1/chat/completions}"
MODEL="${LOCAL_MODEL_NAME:-local-model}"

# ---- 解析参数 ----
USER_PROMPT=""
SYSTEM_PROMPT="你是一位专注成人向（18+）虚构小说创作的写作助手，擅长第一人称沉浸式与多视角叙事，遵循用户指定的风格与 NSFW 档位进行创作。"
TEMPERATURE="0.85"
MAX_TOKENS="1024"

if [ -t 0 ]; then
  # 没有管道输入：第一个参数是用户提示词
  USER_PROMPT="${1:-}"
  [ $# -ge 2 ] && SYSTEM_PROMPT="$2"
  [ $# -ge 3 ] && TEMPERATURE="$3"
  [ $# -ge 4 ] && MAX_TOKENS="$4"
else
  # 有管道输入：从 stdin 读取用户提示词
  USER_PROMPT="$(cat)"
  [ $# -ge 1 ] && SYSTEM_PROMPT="$1"
  [ $# -ge 2 ] && TEMPERATURE="$2"
  [ $# -ge 3 ] && MAX_TOKENS="$3"
fi

if [ -z "$USER_PROMPT" ]; then
  echo "用法: echo '提示词' | bash generate.sh [system_prompt] [temperature] [max_tokens]" >&2
  echo "   或: bash generate.sh '用户提示词' ['系统提示词' [temperature [max_tokens]]]" >&2
  exit 1
fi

# ---- 构造请求体并调用 ----
python3 - "$ENDPOINT" "$MODEL" "$SYSTEM_PROMPT" "$USER_PROMPT" "$TEMPERATURE" "$MAX_TOKENS" <<'PY'
import sys, json, urllib.request

endpoint, model, system_p, user_p, temp, maxt = sys.argv[1:7]

payload = {
    "model": model,
    "messages": [
        {"role": "system", "content": system_p},
        {"role": "user", "content": user_p},
    ],
    "temperature": float(temp),
    "max_tokens": int(maxt),
    "stream": False,
}

data = json.dumps(payload).encode("utf-8")
req = urllib.request.Request(
    endpoint,
    data=data,
    headers={"Content-Type": "application/json"},
    method="POST",
)

try:
    with urllib.request.urlopen(req, timeout=300) as resp:
        body = json.loads(resp.read().decode("utf-8"))
    print(body["choices"][0]["message"]["content"], end="")
except urllib.error.HTTPError as e:
    print(f"[generate.sh] HTTP 错误 {e.code}: {e.read().decode('utf-8', 'replace')[:500]}", file=sys.stderr)
    sys.exit(2)
except Exception as e:
    print(f"[generate.sh] 调用本地模型失败: {e}", file=sys.stderr)
    print(f"[generate.sh] 请确认 LOCAL_MODEL_ENDPOINT（当前={endpoint}）可用且为 OpenAI 兼容 Chat Completions 接口。", file=sys.stderr)
    sys.exit(3)
PY
