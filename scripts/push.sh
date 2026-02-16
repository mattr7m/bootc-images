#!/bin/bash
set -euo pipefail

REGISTRY="${REGISTRY:?REGISTRY must be set (e.g. ghcr.io/youruser)}"
BASE_TAG="${BASE_TAG:-latest}"
NIDUS_TAG="${NIDUS_TAG:-latest}"

BASE_IMAGE="${REGISTRY}/bootc-base:${BASE_TAG}"
NIDUS_IMAGE="${REGISTRY}/bootc-nidus:${NIDUS_TAG}"

usage() {
    echo "Usage: REGISTRY=ghcr.io/youruser $0 {base|nidus|all}"
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY   — image registry (required)"
    echo "  BASE_TAG   — base image tag (default: latest)"
    echo "  NIDUS_TAG  — nidus image tag (default: latest)"
    exit 1
}

push_base() {
    echo "Pushing ${BASE_IMAGE}..."
    podman push "${BASE_IMAGE}"
}

push_nidus() {
    echo "Pushing ${NIDUS_IMAGE}..."
    podman push "${NIDUS_IMAGE}"
}

case "${1:-}" in
    base)
        push_base
        ;;
    nidus)
        push_nidus
        ;;
    all)
        push_base
        push_nidus
        ;;
    *)
        usage
        ;;
esac
