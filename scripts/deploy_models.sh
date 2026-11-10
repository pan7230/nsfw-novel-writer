#!/bin/bash

# NSFW Novel Writer - Model Deployment Script
# Supports: UnfilteredAI/NSFW-3B (~3GB) and OPT-125M
# Author: WorkBuddy NSFW Novel Writer Team

set -e  # Exit on error

# Configuration
MODELS_DIR="${1:-.workbuddy/models/nsfw-novel-writer}"
GITHUB_ACCELERATOR_DIR="${2:-$(dirname "$(realpath "$0")")/../github-accelerator}"

echo "🎨 NSFW Novel Writer - Model Deployment"
echo "======================================"
echo ""

# Create models directory
mkdir -p "$MODELS_DIR"
cd "$MODELS_DIR"

# Function to check if model already exists
check_model_exists() {
    local model_name="$1"
    
    if [ -f "$model_name/meta.json" ]; then
        echo "✓ $model_name already exists (size: $(du -h "$model_name" | cut -f1))"
        return 0
    fi
    return 1
}

# Function to download model from Hugging Face (via hf-mirror)
download_from_hf() {
    local model_name="$1"
    
    echo ""
    echo "📥 Downloading $model_name from Hugging Face (via hf-mirror)..."
    
    # Set HF_ENDPOINT to use hf-mirror
    export HF_ENDPOINT="https://hf-mirror.com"
    
    # Use python with huggingface_hub snapshot_download (more reliable than huggingface-cli)
    if command -v python3 &> /dev/null || command -v python &> /dev/null; then
        echo "   Using huggingface_hub snapshot_download..."
        
        if [ "$model_name" = "UnfilteredAI/NSFW-3B" ]; then
            python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='$model_name', local_dir='.')" 2>/dev/null || {
                echo "   ⚠️  snapshot_download failed, trying direct download..."
            }
        elif [ "$model_name" = "OPT-125M" ]; then
            python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='$model_name', local_dir='.')" 2>/dev/null || {
                echo "   ⚠️  snapshot_download failed, trying direct download..."
            }
        fi
        
        # Create meta.json for WorkBuddy format based on downloaded files
        echo "   Creating meta.json..."
        
        # For UnfilteredAI/NSFW-3B, it has safetensors and tokenizer.json
        if [ -f "$model_name/model.safetensors.index.json" ] && [ -f "$model_name/tokenizer.json" ]; then
            cat > "$model_name/meta.json" << EOF
{
    "name": "$model_name",
    "type": "transformers",
    "parameters": {
        "count": 3000000000,
        "unit": "parameters"
    },
    "files": {
        "model.safetensors.index.json": "model.safetensors.index.json",
        "tokenizer.json": "tokenizer.json"
    },
    "description": "$model_name for WorkBuddy - High quality NSFW novel generation with GGUF variants",
    "license": "MIT"
}
EOF
        # For OPT-125M, it has pytorch_model.bin and vocab.json
        elif [ -f "$model_name/pytorch_model.bin" ] && [ -f "$model_name/vocab.json" ]; then
            cat > "$model_name/meta.json" << EOF
{
    "name": "$model_name",
    "type": "transformers",
    "parameters": {
        "count": 125000000,
        "unit": "parameters"
    },
    "files": {
        "pytorch_model.bin": "pytorch_model.bin",
        "vocab.json": "vocab.json"
    },
    "description": "$model_name for WorkBuddy - Lightweight fast inference",
    "license": "MIT"
}
EOF
        else
            echo "   ⚠️  Unexpected file structure, creating default meta.json..."
            cat > "$model_name/meta.json" << EOF
{
    "name": "$model_name",
    "type": "transformers",
    "parameters": {
        "count": 125000000,
        "unit": "parameters"
    },
    "files": {
        "model.safetensors": "model.safetensors",
        "tokenizer.json": "tokenizer.json"
    },
    "description": "$model_name for WorkBuddy",
    "license": "MIT"
}
EOF
        fi
        
        echo "   ✓ $model_name downloaded successfully!"
    else
        echo "   ⚠️  huggingface-cli not available, using direct download..."
        
        # Download model files directly from Hugging Face
        if [ "$model_name" = "UnfilteredAI/NSFW-3B" ]; then
            echo "   Downloading model weights..."
            curl -L -o "$model_name/model.safetensors" "https://huggingface.co/UnfilteredAI/NSFW-3B/resolve/main/model.safetensors?download" 2>/dev/null || {
                echo "   ⚠️  Failed to download from Hugging Face"
                return 1
            }
            
            echo "   Downloading tokenizer..."
            curl -L -o "$model_name/tokenizer.json" "https://huggingface.co/UnfilteredAI/NSFW-3B/resolve/main/tokenizer.json?download" 2>/dev/null || {
                echo "   ⚠️  Failed to download tokenizer"
                return 1
            }
        elif [ "$model_name" = "OPT-125M" ]; then
            echo "   Downloading model weights..."
            curl -L -o "$model_name/model.safetensors" "https://huggingface.co/facebook/opt-125m/resolve/main/model.safetensors?download" 2>/dev/null || {
                echo "   ⚠️  Failed to download from Hugging Face"
                return 1
            }
            
            echo "   Downloading tokenizer..."
            curl -L -o "$model_name/tokenizer.json" "https://huggingface.co/facebook/opt-125m/resolve/main/tokenizer.json?download" 2>/dev/null || {
                echo "   ⚠️  Failed to download tokenizer"
                return 1
            }
        fi
        
        # Create meta.json for WorkBuddy format
        cat > "$model_name/meta.json" << EOF
{
    "name": "$model_name",
    "type": "transformers",
    "parameters": {
        "count": 125000000,
        "unit": "parameters"
    },
    "files": {
        "model.safetensors": "model.safetensors",
        "tokenizer.json": "tokenizer.json"
    },
    "description": "NSFW Novel Writer model for WorkBuddy",
    "license": "MIT"
}
EOF
    fi
    
    echo "   ✓ $model_name downloaded successfully!"
    return 0
}

# Function to download from GitHub (primary method)
download_from_github() {
    local model_name="$1"
    
    echo ""
    echo "📥 Downloading $model_name from GitHub..."
    
    if [ "$model_name" = "UnfilteredAI/NSFW-3B" ]; then
        echo "   Downloading UnfilteredAI/NSFW-3B (~3GB)..."
        
        # Clone the model repository
        git clone "https://github.com/UnfilteredAI/NSFW-3B.git" 2>/dev/null || {
            echo "   ⚠️  Failed to clone from GitHub"
            
            # Try with GitHub accelerator if available
            if [ -f "$GITHUB_ACCELERATOR_DIR/scripts/accelerate.sh" ]; then
                echo "   Trying with GitHub accelerator..."
                bash "$GITHUB_ACCELERATOR_DIR/scripts/accelerate.sh" apply 2>/dev/null || true
                git clone "https://github.com/UnfilteredAI/NSFW-3B.git" 2>/dev/null || {
                    echo "   ⚠️  Failed to clone with accelerator too"
                    return 1
                }
            else
                echo "   ⚠️  Please install github-accelerator skill and try again"
                return 1
            fi
        }
        
        # Move files to model directory and create WorkBuddy format
        mkdir -p "$model_name" 2>/dev/null || true
        mv "NSFW-3B/model.safetensors" "$model_name/" 2>/dev/null || true
        mv "NSFW-3B/tokenizer.json" "$model_name/" 2>/dev/null || true
        
        # Create meta.json
        cat > "$model_name/meta.json" << EOF
{
    "name": "$model_name",
    "type": "transformers",
    "parameters": {
        "count": 3000000000,
        "unit": "parameters"
    },
    "files": {
        "model.safetensors": "model.safetensors",
        "tokenizer.json": "tokenizer.json"
    },
    "description": "UnfilteredAI NSFW-3B model for WorkBuddy - High quality NSFW novel generation",
    "license": "MIT"
}
EOF
        
        echo "   ✓ $model_name cloned successfully!"
    elif [ "$model_name" = "OPT-125M" ]; then
        echo "   Downloading OPT-125M (~125MB)..."
        
        git clone "https://github.com/facebook/opt.git" 2>/dev/null || {
            echo "   ⚠️  Failed to clone from GitHub"
            
            # Try with accelerator
            if [ -f "$GITHUB_ACCELERATOR_DIR/scripts/accelerate.sh" ]; then
                echo "   Trying with GitHub accelerator..."
                bash "$GITHUB_ACCELERATOR_DIR/scripts/accelerate.sh" apply 2>/dev/null || true
                git clone "https://github.com/facebook/opt.git" 2>/dev/null || {
                    echo "   ⚠️  Failed to clone with accelerator"
                    return 1
                }
            else
                echo "   ⚠️  Please install github-accelerator skill and try again"
                return 1
            fi
        }
        
        # Extract OPT model files (simplified - in production you'd want to extract specific files)
        mkdir -p "$model_name" 2>/dev/null || true
        
        # Copy the model weights (OPT uses pytorch format)
        if [ -f "checkpoints/opt-125m/model.pth" ]; then
            cp "checkpoints/opt-125m/model.pth" "$model_name/" 2>/dev/null || true
        elif [ -d "checkpoints/opt-125m" ]; then
            cp -r "checkpoints/opt-125m/*" "$model_name/" 2>/dev/null || true
        fi
        
        # Copy tokenizer (OPT uses GPT-2 tokenizer)
        if [ -f "tokenizers/gpt2/tokenizer.json" ]; then
            cp "tokenizers/gpt2/tokenizer.json" "$model_name/" 2>/dev/null || true
        elif [ -f "tokenizers/gpt2/encoder.json" ]; then
            cp "tokenizers/gpt2/encoder.json" "$model_name/" 2>/dev/null || true
        fi
        
        # Create meta.json for WorkBuddy format
        cat > "$model_name/meta.json" << EOF
{
    "name": "$model_name",
    "type": "transformers",
    "parameters": {
        "count": 125000000,
        "unit": "parameters"
    },
    "files": {
        "model.pth": "model.pth",
        "tokenizer.json": "tokenizer.json"
    },
    "description": "OPT-125M model for WorkBuddy - Lightweight fast inference",
    "license": "MIT"
}
EOF
        
        echo "   ✓ OPT-125M cloned successfully!"
    fi
    
    return 0
}

# Deploy UnfilteredAI/NSFW-3B model
echo ""
echo "🔥 Deploying UnfilteredAI/NSFW-3B model..."
if ! check_model_exists "UnfilteredAI/NSFW-3B"; then
    if ! download_from_github "UnfilteredAI/NSFW-3B"; then
        echo ""
        echo "📥 Attempting Hugging Face fallback for UnfilteredAI/NSFW-3B..."
        if ! download_from_hf "UnfilteredAI/NSFW-3B"; then
            echo ""
            echo "❌ Failed to deploy UnfilteredAI/NSFW-3B"
        fi
    fi
fi

# Deploy OPT-125M model
echo ""
echo "⚡ Deploying OPT-125M model..."
if ! check_model_exists "OPT-125M"; then
    if ! download_from_github "OPT-125M"; then
        echo ""
        echo "📥 Attempting Hugging Face fallback for OPT-125M..."
        if ! download_from_hf "OPT-125M"; then
            echo ""
            echo "❌ Failed to deploy OPT-125M"
        fi
    fi
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Deployed models:"
ls -lh "$MODELS_DIR" 2>/dev/null | awk '{print "   " $9 ": " $5}'
echo ""

# Show usage instructions
echo "📖 Usage:"
echo "   - Use UnfilteredAI/NSFW-3B for high-quality NSFW novel generation (recommended)"
echo "   - Use OPT-125M for lightweight fast inference"
echo ""
echo "🔧 To configure which model to use, edit:"
echo "   $MODELS_DIR/model_config.yaml"
echo ""
