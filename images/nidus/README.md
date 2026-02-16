# Nidus — Strix Halo AI Workstation

Fedora bootc image for AMD Strix Halo systems, designed as the host OS for running
kyuz0 AI toolboxes. Derives from the base image.

## Image Hierarchy

```
quay.io/fedora/fedora-bootc:43
  └── base       — git, gh, tmux, curl, wget, htop, emacs, jq
        ├── nidus  — podman, toolbox, distrobox, tuned, pciutils, usbutils, lm_sensors, linux-firmware
        └── dev    — podman, python3, php, gcc, claude-code
```

## Hardware Target

- AMD Strix Halo (Ryzen AI 300 / Ryzen AI Max) with integrated RDNA 3.5 GPU
- 128 GB unified memory systems (kernel parameters tuned accordingly)

## Added Packages

| Package | Purpose |
|---|---|
| `podman` | Container runtime |
| `toolbox`, `distrobox` | Container tooling for AI toolboxes |
| `tuned` | Performance tuning (accelerator-performance profile) |
| `pciutils`, `usbutils` | Hardware inspection |
| `lm_sensors` | Temperature/voltage monitoring |
| `linux-firmware` | GPU firmware for Strix Halo |

## Configuration Files

| File | Description |
|---|---|
| `config/usr/lib/bootc/kargs.d/01-strix-halo.toml` | Kernel boot parameters for unified memory |
| `config/usr/lib/udev/rules.d/99-amd-kfd.rules` | udev rules for GPU device access (`/dev/kfd`, `/dev/dri`) |
| `config/usr/lib/systemd/system/strix-halo-firstboot.service` | Oneshot service to configure tuned on first boot |
| `config/usr/local/bin/strix-halo-firstboot.sh` | Sets `accelerator-performance` tuned profile |
| `config/usr/local/bin/strix-halo-setup-toolboxes.sh` | Creates kyuz0 AI toolboxes (Vulkan RADV, ROCm, vLLM) |

## Build

```bash
# Using make (builds base automatically)
make build-nidus

# Manual
podman build -t bootc-base:latest images/base/
podman build --build-arg BASE_IMAGE=localhost/bootc-base:latest \
    -t bootc-nidus:latest images/nidus/
```

## Deployment with bootc-image-builder

The `config.toml` file (at repository level, NOT inside `config/`) is an input for
`bootc-image-builder`. Edit it with your username, password/SSH key, and groups:

```bash
# Build a disk image for installation
sudo podman run --rm -it --privileged \
    --pull=newer \
    -v ./config.toml:/config.toml:ro \
    -v ./output:/output \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type raw-disk \
    --config /config.toml \
    localhost/bootc-nidus:latest
```

## BIOS Notes

For Strix Halo systems, ensure these BIOS settings:

- **UMA Frame Buffer Size** → Auto or maximum
- **IOMMU** → Disabled (matches `amd_iommu=off` karg)
- **Resize BAR** → Enabled

## Verification

```bash
# Check config files landed correctly
podman run --rm localhost/bootc-nidus:latest \
    cat /usr/lib/bootc/kargs.d/01-strix-halo.toml

# Verify services are enabled
podman run --rm localhost/bootc-nidus:latest \
    systemctl is-enabled tuned strix-halo-firstboot.service

# Verify inherited base packages
podman run --rm localhost/bootc-nidus:latest \
    which git jq podman emacs
```
