# bootc-images

Fedora bootc image definitions using a base/derivative pattern.

## Image Hierarchy

```
quay.io/fedora/fedora-bootc:43
  └── base          — common packages and configuration
        └── nidus   — AMD Strix Halo AI workstation
```

## Quick Start

```bash
# Build all images
make build-all

# Build individually
make build-base
make build-nidus

# Push to a registry
make push-all REGISTRY=ghcr.io/youruser
```

## Repository Structure

```
bootc-images/
├── common/              # Shared config (future use)
├── images/
│   ├── base/            # Base image: general-purpose packages
│   └── nidus/           # Strix Halo AI workstation derivative
├── scripts/
│   ├── build.sh         # Build helper
│   └── push.sh          # Push helper
└── Makefile             # Primary build interface
```

## Adding a New Image

1. Create `images/<name>/Containerfile` with `FROM` pointing to base (or another derivative)
2. Add a `config/` directory if the image needs filesystem overlays
3. Add build targets to the `Makefile`
4. Document the image in `images/<name>/README.md`
