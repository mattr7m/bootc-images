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

Each image creates a default user at build time via `sysusers.d` (base/dev: `user`, nidus: `noctua`). Login credentials (password, SSH key) are applied at install time through `config.toml`, which is **gitignored** because it contains hashed passwords.

To create one, copy the example and edit it:

```bash
cp images/nidus/config.toml.example images/nidus/config.toml
# Edit to set your password hash and SSH public key
```

Generate a hashed password with:

```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword'))"
```

A `config.toml` is only used during ISO builds (`make iso-*`). Without one, the ISO will have no login credentials configured. Credentials are injected via a kickstart `%post` script because Anaconda silently skips `[[customizations.user]]` for users that already exist in the image:

```toml
[customizations.installer.kickstart]
contents = """
%post
echo 'noctua:$6$rounds=...' | chpasswd -e
mkdir -p /var/home/noctua/.ssh
echo 'ssh-ed25519 AAAA...' >> /var/home/noctua/.ssh/authorized_keys
chmod 700 /var/home/noctua/.ssh
chmod 600 /var/home/noctua/.ssh/authorized_keys
chown -R noctua:noctua /var/home/noctua/.ssh
restorecon -R /var/home/noctua/.ssh
%end
"""
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
