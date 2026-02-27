# Nidus — Strix Halo AI Workstation

![Nidus](nidus-banner.jpg)

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

## AI Toolboxes

Nidus is designed as the host OS for [kyuz0/amd-strix-halo-toolboxes](https://github.com/kyuz0/amd-strix-halo-toolboxes) — pre-built toolbox containers for running large language models on Strix Halo integrated GPUs using llama.cpp. The project provides containers with multiple GPU backends:

- **Vulkan** (AMDVLK and Mesa RADV) for broad compatibility
- **ROCm** (6.4.4, 7.2, and nightly) for performance-focused inference

The `strix-halo-setup-toolboxes.sh` script (included in this image) creates these toolboxes on first login. The host image provides the kernel parameters, udev rules, and group memberships needed for GPU passthrough into the containers.

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

## User: noctua

The default `user` account (UID 1000) is inherited from the base image. At install time, the `%post` script in `config.toml` renames it to `noctua`, adds `video` and `render` group memberships for GPU access, and sets credentials:

```bash
cp images/nidus/config.toml.example images/nidus/config.toml
# Edit to set password hash and SSH public key
make iso-nidus
```

See `config.toml.example` for the full format.

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
