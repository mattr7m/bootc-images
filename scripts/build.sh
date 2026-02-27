#!/bin/bash
set -euo pipefail

REGISTRY="${REGISTRY:-localhost}"
BASE_TAG="${BASE_TAG:-latest}"
NIDUS_TAG="${NIDUS_TAG:-latest}"
DEV_TAG="${DEV_TAG:-latest}"

BASE_IMAGE="${REGISTRY}/bootc-base:${BASE_TAG}"
NIDUS_IMAGE="${REGISTRY}/bootc-nidus:${NIDUS_TAG}"
DEV_IMAGE="${REGISTRY}/bootc-dev:${DEV_TAG}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

usage() {
    echo "Usage: $0 {base|nidus|dev|all}"
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY   — image registry (default: localhost)"
    echo "  BASE_TAG   — base image tag (default: latest)"
    echo "  NIDUS_TAG  — nidus image tag (default: latest)"
    echo "  DEV_TAG    — dev image tag (default: latest)"
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

build_dev() {
    echo "Building ${DEV_IMAGE}..."
    podman build \
        --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
        -t "${DEV_IMAGE}" \
        "${REPO_ROOT}/images/dev/"
}

case "${1:-}" in
    base)
        build_base
        ;;
    nidus)
        build_base
        build_nidus
        ;;
    dev)
        build_base
        build_dev
        ;;
    all)
        build_base
        build_nidus
        build_dev
        ;;
    *)
        usage
        ;;
esac
