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
- `podman` — container runtime

## Build

```bash
make build-base
# or
podman build -t bootc-base:latest images/base/
```
