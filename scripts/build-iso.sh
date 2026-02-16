#!/bin/bash
set -euo pipefail

REGISTRY="${REGISTRY:-localhost}"
BASE_TAG="${BASE_TAG:-latest}"
NIDUS_TAG="${NIDUS_TAG:-latest}"
DEV_TAG="${DEV_TAG:-latest}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

usage() {
    echo "Usage: $0 {base|nidus|dev|all}"
    echo ""
    echo "Builds Anaconda ISOs using bootc-image-builder."
    echo "Must be run as root (uses privileged podman)."
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY   — image registry (default: localhost)"
    echo "  BASE_TAG   — base image tag (default: latest)"
    echo "  NIDUS_TAG  — nidus image tag (default: latest)"
    echo "  DEV_TAG    — dev image tag (default: latest)"
    exit 1
}

# Require root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Error: must be run as root (bootc-image-builder requires --privileged)"
    exit 1
fi

build_iso() {
    local name="$1"
    local image_ref="$2"
    local output_dir="${REPO_ROOT}/output/${name}"
    local config_toml="${REPO_ROOT}/images/${name}/config.toml"

    echo "=== Building ISO for ${name} (${image_ref}) ==="

    mkdir -p "${output_dir}"

    local volume_args=()
    local builder_args=()
    if [[ -f "${config_toml}" ]]; then
        echo "Using config: ${config_toml}"
        volume_args=(-v "${config_toml}:/config.toml:ro")
        builder_args=(--config /config.toml)
    else
        echo "Warning: ${config_toml} not found, building ISO without user customization"
    fi

    podman run --rm -it --privileged \
        --pull=newer \
        -v "${output_dir}:/output" \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        "${volume_args[@]:+${volume_args[@]}}" \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type anaconda-iso \
        --rootfs xfs \
        "${builder_args[@]:+${builder_args[@]}}" \
        "${image_ref}"

    echo "=== ISO written to ${output_dir}/ ==="
}

case "${1:-}" in
    base)
        build_iso base "${REGISTRY}/bootc-base:${BASE_TAG}"
        ;;
    nidus)
        build_iso nidus "${REGISTRY}/bootc-nidus:${NIDUS_TAG}"
        ;;
    dev)
        build_iso dev "${REGISTRY}/bootc-dev:${DEV_TAG}"
        ;;
    all)
        build_iso base "${REGISTRY}/bootc-base:${BASE_TAG}"
        build_iso nidus "${REGISTRY}/bootc-nidus:${NIDUS_TAG}"
        build_iso dev "${REGISTRY}/bootc-dev:${DEV_TAG}"
        ;;
    *)
        usage
        ;;
esac
