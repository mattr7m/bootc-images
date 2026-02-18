# bootc-images

Fedora bootc image definitions using a base/derivative pattern.

## Image Hierarchy

```
quay.io/fedora/fedora-bootc:43
  └── base          — git, gh, tmux, curl, wget, htop, emacs, jq
        ├── nidus   — podman, toolbox, distrobox, tuned, pciutils, usbutils, lm_sensors, linux-firmware
        └── dev     — podman, python3, php, gcc, claude-code
```

## Install-time Configuration (optional)

Each image creates a default `user` account (UID 1000) at build time via `sysusers.d`. Hostname, username, login credentials, and SSH keys are applied at install time through `config.toml`, which is **gitignored** because it contains secrets. The `%post` script renames the default account to your chosen username (nidus defaults to `noctua`).

To create one, copy the example and edit it:

```bash
cp images/dev/config.toml.example images/dev/config.toml
# Edit to set hostname, username, password hash, and SSH public key
```

Generate a hashed password with:

```bash
python3 -c "import crypt; print(crypt.crypt('yourpassword'))"
```

A `config.toml` is only used during ISO builds (`make iso-*`). Without one, the ISO will have no login credentials or hostname configured. Configuration is injected via a kickstart `%post` script because Anaconda silently skips `[[customizations.user]]` for users that already exist in the image. The script renames the default `user` account and sets credentials:

```toml
[customizations.installer.kickstart]
contents = """
%post --log=/var/log/anaconda/ks-post.log
# Hostname
echo 'myhost' > /etc/hostname

# Rename default user → your username
usermod -l youruser user
groupmod -n youruser user
usermod -d /home/youruser -m youruser

# User password
echo 'youruser:$6$rounds=...' | chpasswd -e

# SSH authorized key
mkdir -p /var/home/youruser/.ssh
echo 'ssh-ed25519 AAAA...' >> /var/home/youruser/.ssh/authorized_keys
chmod 700 /var/home/youruser/.ssh
chmod 600 /var/home/youruser/.ssh/authorized_keys
chown -R youruser:youruser /var/home/youruser/.ssh
restorecon -R /var/home/youruser/.ssh
%end
"""
```

If the `%post` script fails, check `/var/log/anaconda/ks-post.log` on the installed system.

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
