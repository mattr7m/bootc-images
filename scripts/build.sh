#!/bin/bash
set -euo pipefail

REGISTRY="${REGISTRY:-localhost}"
BASE_TAG="${BASE_TAG:-latest}"
NIDUS_TAG="${NIDUS_TAG:-latest}"

BASE_IMAGE="${REGISTRY}/bootc-base:${BASE_TAG}"
NIDUS_IMAGE="${REGISTRY}/bootc-nidus:${NIDUS_TAG}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

usage() {
    echo "Usage: $0 {base|nidus|all}"
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY   — image registry (default: localhost)"
    echo "  BASE_TAG   — base image tag (default: latest)"
    echo "  NIDUS_TAG  — nidus image tag (default: latest)"
    exit 1
}

build_base() {
    echo "Building ${BASE_IMAGE}..."
    podman build -t "${BASE_IMAGE}" "${REPO_ROOT}/images/base/"
}

build_nidus() {
    echo "Building ${NIDUS_IMAGE}..."
    podman build \
        --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
        -t "${NIDUS_IMAGE}" \
        "${REPO_ROOT}/images/nidus/"
}

case "${1:-}" in
    base)
        build_base
        ;;
    nidus)
        build_base
        build_nidus
        ;;
    all)
        build_base
        build_nidus
        ;;
    *)
        usage
        ;;
esac
