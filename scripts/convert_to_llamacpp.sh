#!/bin/bash

# NSFW Novel Writer - Convert Safetensors to GGUF for llama.cpp
# This script converts the UnfilteredAI/NSFW-3B safetensors model to GGUF format

set -e  # Exit on error

MODELS_DIR="${1:-.workbuddy/models/nsfw-novel-writer}"
LLAMA_CPP_PATH="${2:-$(which llama.cpp 2>/dev/null || echo "")}"

echo "🔧 Converting UnfilteredAI/NSFW-3B to GGUF format for llama.cpp"
echo "=============================================================="
echo ""

cd "$MODELS_DIR"

# Check if llama.cpp is available
if [ -z "$LLAMA_CPP_PATH" ]; then
    echo "⚠️  llama.cpp not found in PATH."
    echo ""
    echo "   Install it using one of the following methods:"
    echo "   - macOS: brew install llama.cpp"
    echo "   - Linux: curl -LsSf https://llama.app/install.sh | sh"
    echo "   - Windows: winget install llama.cpp"
    echo ""
    exit 1
fi

# Check if the safetensors model exists
if [ ! -f "$MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors" ]; then
    echo "❌ Model not found: $MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors"
    echo ""
    echo "   Please deploy the model first using:"
    echo "   ./deploy_models.sh"
    exit 1
fi

# Create output directory for GGUF models
GGUF_DIR="$MODELS_DIR/gguf"
mkdir -p "$GGUF_DIR"

echo "📁 Output directory: $GGUF_DIR"
echo ""

# Convert to different quantization levels
echo "🔥 Converting with various quantizations..."
echo ""

# Q8_0 - Maximum quality, largest size (~3GB)
echo "   Converting to Q8_0 (maximum quality, ~3.2GB)..."
"$LLAMA_CPP_PATH" convert-safetensors "$MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors" \
    -o "$GGUF_DIR/nsfw-3b-q8_0.gguf" \
    --outfile-type gguf 2>/dev/null || {
        echo "   ⚠️  Q8_0 conversion failed"
    }

# Q5_K_M - Good quality/size balance (~2.1GB)
echo "   Converting to Q5_K_M (good quality, ~2.1GB)..."
"$LLAMA_CPP_PATH" convert-safetensors "$MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors" \
    -o "$GGUF_DIR/nsfw-3b-q5_k_m.gguf" \
    --outfile-type gguf 2>/dev/null || {
        echo "   ⚠️  Q5_K_M conversion failed"
    }

# Q4_K_M - Recommended balance (~1.5GB)
echo "   Converting to Q4_K_M (recommended, ~1.5GB)..."
"$LLAMA_CPP_PATH" convert-safetensors "$MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors" \
    -o "$GGUF_DIR/nsfw-3b-q4_k_m.gguf" \
    --outfile-type gguf 2>/dev/null || {
        echo "   ⚠️  Q4_K_M conversion failed"
    }

# Q4_0 - Smaller size (~1.2GB)
echo "   Converting to Q4_0 (smaller, ~1.2GB)..."
"$LLAMA_CPP_PATH" convert-safetensors "$MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors" \
    -o "$GGUF_DIR/nsfw-3b-q4_0.gguf" \
    --outfile-type gguf 2>/dev/null || {
        echo "   ⚠️  Q4_0 conversion failed"
    }

# Q3_K_M - Smallest size (~850MB)
echo "   Converting to Q3_K_M (smallest, ~850MB)..."
"$LLAMA_CPP_PATH" convert-safetensors "$MODELS_DIR/UnfilteredAI/NSFW-3B/model.safetensors" \
    -o "$GGUF_DIR/nsfw-3b-q3_k_m.gguf" \
    --outfile-type gguf 2>/dev/null || {
        echo "   ⚠️  Q3_K_M conversion failed"
    }

echo ""
echo "✅ Conversion complete!"
echo ""
echo "📊 Converted models:"
ls -lh "$GGUF_DIR"/*.gguf 2>/dev/null | awk '{print "   " $9 ": " $5}'
echo ""

# Show usage instructions
echo "📖 Usage with llama.cpp:"
echo ""
echo "# Start server (recommended Q4_K_M):"
echo "   llama-server -m $GGUF_DIR/nsfw-3b-q4_k_m.gguf -port 8080"
echo ""
echo "# Run inference:"
echo "   llama-cli -m $GGUF_DIR/nsfw-3b-q4_k_m.gguf"
echo ""
echo "# Use specific quantization:"
echo "   llama-server -m $GGUF_DIR/nsfw-3b-q8_0.gguf -port 8080  # Best quality"
echo "   llama-server -m $GGUF_DIR/nsfw-3b-q4_k_m.gguf -port 8080  # Best balance"
echo "   llama-server -m $GGUF_DIR/nsfw-3b-q4_0.gguf -port 8080   # Smaller"
echo "   llama-server -m $GGUF_DIR/nsfw-3b-q3_k_m.gguf -port 8080 # Smallest"
echo ""
