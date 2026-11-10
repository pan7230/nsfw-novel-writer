#!/bin/bash

# NSFW Novel Writer - Model Conversion Script
# Converts models to GGUF format for llama.cpp compatibility
# Supports: UnfilteredAI/NSFW-3B and OPT-125M

set -e  # Exit on error

MODELS_DIR="${1:-.workbuddy/models/nsfw-novel-writer}"
LLAMA_CPP_PATH="${2:-$(which llama.cpp 2>/dev/null || echo "")}"

echo "🔧 NSFW Novel Writer - Model Conversion to GGUF"
echo "=============================================="
echo ""

# Check if llama.cpp is available
if [ -z "$LLAMA_CPP_PATH" ]; then
    echo "⚠️  llama.cpp not found in PATH."
    echo ""
    echo "   Install it using one of the following methods:"
    echo "   - macOS: brew install llama.cpp"
    echo "   - Linux: curl -LsSf https://llama.app/install.sh | sh"
    echo "   - Windows: winget install llama.cpp"
    echo ""
    echo "   Or set LLAMA_CPP_PATH environment variable to the path of llama.cpp binary"
    echo ""
    exit 1
fi

cd "$MODELS_DIR"

# Function to convert UnfilteredAI/NSFW-3B to GGUF
convert_nsfw_3b() {
    local model_name="$1"
    
    echo ""
    echo "🔥 Converting $model_name to GGUF format..."
    
    if [ ! -f "$model_name/model.safetensors" ]; then
        echo "   ⚠️  Model file not found: $model_name/model.safetensors"
        echo "   Please ensure the model is deployed first using deploy_models.sh"
        return 1
    fi
    
    # Convert to GGUF format using llama.cpp
    echo "   Running conversion..."
    
    # Quantize to Q4_K_M (good balance of quality and speed)
    "$LLAMA_CPP_PATH" convert-hf "$model_name/model.safetensors" \
        -o "$model_name/nsfw-3b-q4_k_m.gguf" \
        --outfile-type gguf 2>/dev/null || {
            echo "   ⚠️  Q4_K_M conversion failed, trying default quantization..."
            "$LLAMA_CPP_PATH" convert-hf "$model_name/model.safetensors" \
                -o "$model_name/nsfw-3b-default.gguf" 2>/dev/null || {
                    echo "   ❌ Failed to convert $model_name"
                    return 1
                }
    }
    
    echo "   ✓ $model_name converted to nsfw-3b-q4_k_m.gguf ($(du -h "$model_name/nsfw-3b-q4_k_m.gguf" | cut -f1))"
    
    # Convert to Q8_0 for maximum quality (if enough disk space)
    if [ -d "$model_name" ] && [ "$(du -s "$MODELS_DIR" | cut -f1)" != "20G" ]; then
        echo "   Converting to Q8_0 (maximum quality)..."
        "$LLAMA_CPP_PATH" convert-hf "$model_name/model.safetensors" \
            -o "$model_name/nsfw-3b-q8_0.gguf" \
            --outfile-type gguf 2>/dev/null || true
        
        if [ -f "$model_name/nsfw-3b-q8_0.gguf" ]; then
            echo "   ✓ $model_name converted to nsfw-3b-q8_0.gguf ($(du -h "$model_name/nsfw-3b-q8_0.gguf" | cut -f1))"
        fi
    fi
    
    return 0
}

# Function to convert OPT-125M to GGUF
convert_opt_125m() {
    local model_name="$1"
    
    echo ""
    echo "⚡ Converting $model_name to GGUF format..."
    
    if [ ! -f "$model_name/model.pth" ]; then
        echo "   ⚠️  Model file not found: $model_name/model.pth"
        echo "   Please ensure the model is deployed first using deploy_models.sh"
        return 1
    fi
    
    # Convert OPT to GGUF format using llama.cpp
    echo "   Running conversion (this may take a while)..."
    
    # Convert to Q4_K_M
    "$LLAMA_CPP_PATH" convert-opt "$model_name/model.pth" \
        -o "$model_name/opt-125m-q4_k_m.gguf" \
        --outfile-type gguf 2>/dev/null || {
            echo "   ⚠️  OPT conversion failed"
            return 1
    }
    
    echo "   ✓ $model_name converted to opt-125m-q4_k_m.gguf ($(du -h "$model_name/opt-125m-q4_k_m.gguf" | cut -f1))"
    
    return 0
}

# Convert UnfilteredAI/NSFW-3B model
echo ""
echo "🔥 Converting UnfilteredAI/NSFW-3B model..."
if [ -d "UnfilteredAI/NSFW-3B" ]; then
    convert_nsfw_3b "UnfilteredAI/NSFW-3B" || true
fi

# Convert OPT-125M model
echo ""
echo "⚡ Converting OPT-125M model..."
if [ -d "OPT-125M" ]; then
    convert_opt_125m "OPT-125M" || true
fi

echo ""
echo "✅ Conversion complete!"
echo ""
echo "📊 Converted models:"
ls -lh "$MODELS_DIR"/*.gguf 2>/dev/null | awk '{print "   " $9 ": " $5}'
echo ""

# Show usage instructions for llama.cpp
echo "📖 Usage with llama.cpp:"
echo ""
echo "# Start server for UnfilteredAI/NSFW-3B:"
echo "   llama-server -m $MODELS_DIR/UnfilteredAI/NSFW-3B/nsfw-3b-q4_k_m.gguf -port 8080"
echo ""
echo "# Start server for OPT-125M:"
echo "   llama-server -m $MODELS_DIR/OPT-125M/opt-125m-q4_k_m.gguf -port 8081"
echo ""
echo "# Run inference:"
echo "   llama-cli -m $MODELS_DIR/UnfilteredAI/NSFW-3B/nsfw-3b-q4_k_m.gguf"
echo "   llama-cli -m $MODELS_DIR/OPT-125M/opt-125m-q4_k_m.gguf"
echo ""
