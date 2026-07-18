#!/usr/bin/env bash
set -euo pipefail

git config --global --add safe.directory "$(pwd)"

# Flox environments only activate on the host's own system, and this CI
# runner is Linux -- not the aarch64-darwin the real dotfiles environment
# targets. Reconstructing and activating the full ~50-package global
# environment here would fail unconditionally regardless of the pinned
# versions (it's macOS-only). Instead, build a minimal, throwaway,
# Linux-scoped environment containing only the two pilot packages, purely
# to confirm the pinned version resolves in the Flox catalog at all. This
# does NOT regenerate the real private_manifest.lock -- that requires
# darwin resolution and only happens locally, on a Mac, when the change is
# merged and `flox activate`/`chezmoi apply` is run there.
RIPGREP_VERSION=$(grep -oP 'ripgrep\.version = "\K[^"]+' dot_flox/env/private_manifest.toml)
FD_VERSION=$(grep -oP 'fd\.version = "\K[^"]+' dot_flox/env/private_manifest.toml)

SCRATCH=$(mktemp -d)
mkdir -p "$SCRATCH/.flox/env"
cat > "$SCRATCH/.flox/env.json" <<EOF
{"name":"flox-version-check","version":1}
EOF
cat > "$SCRATCH/.flox/env/manifest.toml" <<EOF
schema-version = "1.11.0"
[install]
ripgrep.pkg-path = "ripgrep"
ripgrep.pkg-group = "ripgrep"
ripgrep.version = "$RIPGREP_VERSION"
fd.pkg-path = "fd"
fd.pkg-group = "fd"
fd.version = "$FD_VERSION"
[options]
systems = ["x86_64-linux", "aarch64-linux"]
EOF

flox activate -d "$SCRATCH" -c "true"
rm -rf "$SCRATCH"
