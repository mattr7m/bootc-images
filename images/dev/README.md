# Dev — Development Workstation

Fedora bootc image for development, with language runtimes, compilers, and Claude Code.
Derives from the base image.

## Image Hierarchy

```
quay.io/fedora/fedora-bootc:43
  └── base       — git, gh, tmux, curl, wget, htop, emacs, jq
        ├── nidus  — podman, toolbox, distrobox, tuned, pciutils, usbutils, lm_sensors, linux-firmware
        └── dev    — podman, python3, php, gcc, claude-code
```

## Added Packages

| Package | Purpose |
|---|---|
| `podman` | Container runtime |
| `python3` | Python interpreter |
| `php` | PHP interpreter |
| `gcc` | GNU C compiler |
| `claude-code` | Anthropic Claude Code CLI (installed via official installer) |

## Build

```bash
# Using make (builds base automatically)
make build-dev

# Manual
podman build -t bootc-base:latest images/base/
podman build --build-arg BASE_IMAGE=localhost/bootc-base:latest \
    -t bootc-dev:latest images/dev/
```

## User: user

The `user` account (UID 1000) is inherited from the base image. Login credentials (password, SSH key) are applied at install time through `config.toml`:

```bash
cp images/dev/config.toml.example images/dev/config.toml
# Edit to set your password hash and SSH public key
make iso-dev
```

Credentials use a kickstart `%post` script because Anaconda silently skips `[[customizations.user]]` for users that already exist in the image. See `config.toml.example` for the format.

## Verification

```bash
# Verify dev packages
podman run --rm localhost/bootc-dev:latest which python3 php gcc claude

# Verify inherited base packages
podman run --rm localhost/bootc-dev:latest which git jq emacs
```
