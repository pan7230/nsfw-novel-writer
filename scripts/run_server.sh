#!/bin/bash

# NSFW Novel Writer - Server Launch Script
# Supports: Transformers, llama.cpp, vLLM

set -e  # Exit on error

MODELS_DIR="${1:-.workbuddy/models/nsfw-novel-writer}"
SERVER_TYPE="${2:-transformers}"  # transformers, llama.cpp, vllm

echo "🚀 NSFW Novel Writer - Server Launch"
echo "======================================"
echo ""

cd "$MODELS_DIR"

# Function to start Transformers server (Flask API)
start_transformers_server() {
    local model_name="$1"
    
    echo "🔥 Starting Transformers server for $model_name..."
    
    if [ ! -f "$MODELS_DIR/$model_name/meta.json" ]; then
        echo "   ⚠️  Model not found: $model_name/meta.json"
        echo "   Please deploy the model first using deploy_models.sh"
        exit 1
    fi
    
    # Check if python and transformers are available
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        echo "   ⚠️  Python not found. Please install Python 3.8+"
        exit 1
    fi
    
    # Create a simple Flask API server script
    cat > "$MODELS_DIR/api_server.py" << 'EOF'
from flask import Flask, request, jsonify
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
import os

app = Flask(__name__)
model_name = os.environ.get('MODEL_NAME', 'UnfilteredAI/NSFW-3B')
device = os.environ.get('DEVICE', 'cuda' if torch.cuda.is_available() else 'cpu')

# Load model and tokenizer
print(f"Loading {model_name} on {device}...")
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    device_map=device,
    trust_remote_code=True
)
print("Model loaded successfully!")

# Chat template for role-based conversation
def generate_response(messages, nsfw_level=3):
    # Convert messages to chat format
    text = ""
    for msg in messages:
        if msg['role'] == 'user':
            text += f"User: {msg['content']}\n"
        elif msg['role'] == 'assistant':
            text += f"Assistant: {msg['content']}\n"
    
    # Generate response with NSFW level control
    prompt = f"""
[System Instruction]
You are an AI assistant for adult-oriented novel writing. 
NSFW Level: {nsfw_level}/4 (0=SFW, 4=maximum intensity)

{text}Assistant:
"""
    
    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
    outputs = model.generate(
        **inputs,
        max_new_tokens=512,
        temperature=0.85,
        top_p=0.9,
        repetition_penalty=1.1
    )
    
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    # Extract assistant's response (after "Assistant:")
    if "Assistant:" in response:
        response = response.split("Assistant:", 1)[1].strip()
    
    return response

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    
    messages = data.get('messages', [])
    nsfw_level = int(data.get('nsfw_level', 3))
    
    try:
        response = generate_response(messages, nsfw_level)
        return jsonify({'response': response})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    print("Starting API server...")
    app.run(host='0.0.0.0', port=5000)
EOF
    
    echo "   Starting server on http://localhost:5000..."
    python3 "$MODELS_DIR/api_server.py" --model-name "$model_name" || {
        echo "   ⚠️  Server failed to start. Check the error message above."
        exit 1
    }

# Function to start llama.cpp server
start_llama_server() {
    local model_path="$1"
    
    echo "🔥 Starting llama.cpp server for $model_path..."
    
    if [ ! -f "$MODELS_DIR/$model_path" ]; then
        echo "   ⚠️  Model file not found: $MODELS_DIR/$model_path"
        echo "   Please convert the model first using convert_models.sh"
        exit 1
    fi
    
    echo "   Starting server on port 8080..."
    
    # Check if llama.cpp is available
    if ! command -v llama-server &> /dev/null; then
        echo "   ⚠️  llama.cpp not found. Please install it:"
        echo "   - macOS: brew install llama.cpp"
        echo "   - Linux: curl -LsSf https://llama.app/install.sh | sh"
        echo "   - Windows: winget install llama.cpp"
        exit 1
    fi
    
    echo "   Starting server..."
    llama-server -m "$MODELS_DIR/$model_path" -port 8080 || {
        echo "   ⚠️  Server failed to start. Check the error message above."
        exit 1
    }

# Function to start vLLM server
start_vllm_server() {
    local model_name="$1"
    
    echo "🔥 Starting vLLM server for $model_name..."
    
    if [ ! -f "$MODELS_DIR/$model_name/meta.json" ]; then
        echo "   ⚠️  Model not found: $model_name/meta.json"
        echo "   Please deploy the model first using deploy_models.sh"
        exit 1
    fi
    
    # Check if vllm is available
    if ! command -v vllm &> /dev/null; then
        echo "   ⚠️  vLLM not found. Please install it:"
        echo "   pip install vllm"
        exit 1
    fi
    
    echo "   Starting server on port 8000..."
    
    # Determine the GGUF file to use
    gguf_file=""
    if [ -f "$MODELS_DIR/$model_name/nsfw-3b-q4_k_m.gguf" ]; then
        gguf_file="$MODELS_DIR/$model_name/nsfw-3b-q4_k_m.gguf"
    elif [ -f "$MODELS_DIR/$model_name/nsfw-3b-default.gguf" ]; then
        gguf_file="$MODELS_DIR/$model_name/nsfw-3b-default.gguf"
    elif [ -f "$MODELS_DIR/$model_name/opt-125m-q4_k_m.gguf" ]; then
        gguf_file="$MODELS_DIR/$model_name/opt-125m-q4_k_m.gguf"
    elif [ -f "$MODELS_DIR/$model_name/model.safetensors" ]; then
        gguf_file="$MODELS_DIR/$model_name/model.safetensors"
    fi
    
    if [ -z "$gguf_file" ]; then
        echo "   ⚠️  No GGUF or safetensors model found for $model_name"
        exit 1
    fi
    
    echo "   Starting server..."
    vllm serve "$gguf_file" --host 0.0.0.0 --port 8000 || {
        echo "   ⚠️  Server failed to start. Check the error message above."
        exit 1
    }

# Main execution
case "$SERVER_TYPE" in
    transformers)
        start_transformers_server "UnfilteredAI/NSFW-3B"
        ;;
    llama.cpp)
        start_llama_server "UnfilteredAI/NSFW-3B/nsfw-3b-q4_k_m.gguf"
        ;;
    vllm)
        start_vllm_server "UnfilteredAI/NSFW-3B"
        ;;
    *)
        echo "❌ Unknown server type: $SERVER_TYPE"
        echo ""
        echo "Usage:"
        echo "   ./run_server.sh [model_name] [server_type]"
        echo ""
        echo "Server types:"
        echo "   - transformers: Flask API server (default)"
        echo "   - llama.cpp: llama.cpp OpenAI-compatible server"
        echo "   - vllm: vLLM high-performance serving engine"
        echo ""
        exit 1
        ;;
esac
