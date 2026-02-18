# Base Image

General-purpose Fedora bootc base image. All derivative images build on top of this.

## Base: `quay.io/fedora/fedora-bootc:43`

## Packages

- `git`, `gh` — version control
- `tmux` — terminal multiplexer
- `curl`, `wget` — network utilities
- `htop` — process monitor
- `emacs` — text editor
- `jq` — JSON processor

## User: user

A default `user` account (UID 1000, `wheel` group, `/bin/bash`) is created at build time via `sysusers.d`. At install time, the `%post` script in `config.toml` renames the account to your chosen username and sets credentials:

```bash
cp images/base/config.toml.example images/base/config.toml
# Edit to set hostname, username, password hash, and SSH public key
```

## Build

```bash
make build-base
# or
podman build -t bootc-base:latest images/base/
```
