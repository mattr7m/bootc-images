# bootc-images

Fedora bootc image definitions using a base/derivative pattern.

## Image Hierarchy

```
quay.io/fedora/fedora-bootc:43
  └── base          — git, gh, tmux, curl, wget, htop, emacs, jq
        ├── nidus   — podman, toolbox, distrobox, tuned, pciutils, usbutils, lm_sensors, linux-firmware
        └── dev     — podman, python3, php, gcc, claude-code
```

## User Configuration (optional)

Each image supports an optional `config.toml` for bootc-image-builder user customization (login credentials, SSH keys). These files are **gitignored** because they may contain hashed passwords.

To create one, copy the example and edit it:

```bash
cp images/base/config.toml.example images/base/config.toml
# Edit to set your username, password, SSH key, and groups
```

Generate a hashed password with:

```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword'))"
```

A `config.toml` is only used during ISO builds (`make iso-*`). Without one, the ISO will have no login credentials configured. The file format:

```toml
[[customizations.user]]
name = "your-username"
password = "$6$rounds=..."
groups = ["wheel", "video", "render"]
# Or use an SSH key (console/TTY login requires a password):
# key = "ssh-ed25519 AAAA..."
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

# Build Anaconda ISOs (images must be staged to root's podman first)
make stage-iso
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
