# bootc-images

Fedora bootc image definitions using a base/derivative pattern.

## Image Hierarchy

```
quay.io/fedora/fedora-bootc:43
  └── base          — git, gh, tmux, curl, wget, htop, emacs, jq
        ├── nidus   — podman, toolbox, distrobox, tuned, pciutils, usbutils, lm_sensors, linux-firmware
        └── dev     — podman, python3, php, gcc, claude-code
```

## Quick Start

```bash
# Build all images
make build-all

# Build individually
make build-base
make build-nidus
make build-dev

# Push to a registry
make push-all REGISTRY=ghcr.io/youruser

# Build Anaconda ISOs
make iso-base
make iso-nidus
make iso-dev
make iso-all
```

## Repository Structure

```
bootc-images/
├── common/              # Shared config (future use)
├── images/
│   ├── base/            # Base image: general-purpose packages
│   ├── nidus/           # Strix Halo AI workstation derivative
│   └── dev/             # Development workstation derivative
├── scripts/
│   ├── build.sh         # Build helper
│   ├── push.sh          # Push helper
│   └── build-iso.sh     # Anaconda ISO builder (bootc-image-builder)
├── output/              # ISO build artifacts (gitignored)
└── Makefile             # Primary build interface
```

## Adding a New Image

1. Create `images/<name>/Containerfile` with `FROM` pointing to base (or another derivative)
2. Add a `config/` directory if the image needs filesystem overlays
3. Add a `config.toml` for bootc-image-builder user customization
4. Add build targets to the `Makefile`
5. Document the image in `images/<name>/README.md`
