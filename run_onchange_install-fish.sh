#!/bin/bash
# Install/upgrade fish via `nix profile` from a pinned nixpkgs ref.
#
# Fish lives outside flox because it is the login shell (see /etc/shells
# and `dscl . -read /Users/shawns UserShell`) — flox activates *after*
# login, so the shell binary needs a stable path that exists before any
# flox env is sourced.
#
# This script is a chezmoi run_onchange_ hook: bumping the pin below
# (NIXPKGS_REV / EXPECTED_VERSION) re-triggers it on the next
# `chezmoi apply`. To upgrade:
#   1. Pick a new nixpkgs commit:  nix flake metadata nixpkgs --json | jq -r .locked.rev
#   2. Confirm fish version:        nix eval --raw "github:NixOS/nixpkgs/<rev>#fish.version"
#   3. Update both variables below and commit.

set -euo pipefail

NIXPKGS_REV="d849bb215dcdf71bce3e686839ccdb4219e84b2f"
EXPECTED_VERSION="4.7.1"
FLAKE_REF="github:NixOS/nixpkgs/${NIXPKGS_REV}#fish"

if ! command -v nix >/dev/null 2>&1; then
    # Source the Determinate/multi-user nix daemon profile if nix isn't on PATH yet.
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # shellcheck disable=SC1091
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi

if ! command -v nix >/dev/null 2>&1; then
    echo "nix not found on PATH; skipping fish install" >&2
    exit 0
fi

# Fast path: already at the pinned version.
if [ -x "$HOME/.nix-profile/bin/fish" ]; then
    CURRENT=$("$HOME/.nix-profile/bin/fish" --version 2>/dev/null | awk '{print $NF}')
    if [ "$CURRENT" = "$EXPECTED_VERSION" ]; then
        echo "fish $CURRENT already installed from pinned ref"
        exit 0
    fi
    echo "fish $CURRENT installed; upgrading to $EXPECTED_VERSION"
fi

# Remove any existing fish entry so we can install from the new flake ref.
# `nix profile install` refuses to replace a same-named package silently.
if nix profile list 2>/dev/null | grep -E '^Name:[[:space:]]+fish$' >/dev/null; then
    nix profile remove fish
fi

nix profile install "$FLAKE_REF"

echo "Installed: $("$HOME/.nix-profile/bin/fish" --version)"
echo
echo "If fish is not yet a registered login shell, run (requires sudo):"
echo "  echo \$HOME/.nix-profile/bin/fish | sudo tee -a /etc/shells"
echo "  chsh -s \$HOME/.nix-profile/bin/fish"
