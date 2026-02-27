#!/bin/bash
set -euo pipefail

echo "=== Strix Halo AI Toolbox Setup ==="
echo ""
echo "This script creates the kyuz0 AI toolboxes with proper GPU access."
echo "Run this as your regular user (not root)."
echo ""

# Vulkan RADV (most stable, recommended for most users)
echo "[1/3] Creating Vulkan RADV toolbox..."
toolbox create llama-vulkan-radv \
  --image docker.io/kyuz0/amd-strix-halo-toolboxes:vulkan-radv \
  -- --device /dev/dri --group-add video --security-opt seccomp=unconfined 2>/dev/null || true

# ROCm 6.4.4 + ROCWMMA (best ROCm option)
echo "[2/3] Creating ROCm 6.4.4 + ROCWMMA toolbox..."
toolbox create llama-rocm-6.4.4-rocwmma \
  --image docker.io/kyuz0/amd-strix-halo-toolboxes:rocm-6.4.4-rocwmma \
  -- --device /dev/dri --device /dev/kfd \
  --group-add video --group-add render --group-add sudo \
  --security-opt seccomp=unconfined 2>/dev/null || true

# vLLM (for serving)
echo "[3/3] Creating vLLM toolbox..."
toolbox create vllm \
  --image docker.io/kyuz0/vllm-therock-gfx1151-aotriton:latest \
  -- --device /dev/dri --device /dev/kfd \
  --group-add video --group-add render \
  --security-opt seccomp=unconfined 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo "Enter a toolbox with: toolbox enter <name>"
echo "  e.g.: toolbox enter llama-vulkan-radv"
