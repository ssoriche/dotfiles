#!/bin/bash
# Install the patched ccstatusline from ssoriche's fork until upstream PR #411
# (sirmalloc/ccstatusline) is merged. The fork's release branch carries the
# fix from sirmalloc/ccstatusline#411 plus a vendored dist/ so that
# `bun install -g` from a git URL produces a working binary at
# ~/.bun/bin/ccstatusline (the upstream package has dist/ gitignored and no
# prepare script, so a plain `bun install -g github:...` against the fix
# branch leaves the binary unresolvable).
#
# This script is a chezmoi run_onchange_ hook: bumping PINNED_COMMIT below
# re-triggers it on the next `chezmoi apply`. To pick up a new fork build:
#   1. Push a new commit on ssoriche/ccstatusline release/fix-flex-separator
#   2. git rev-parse origin/release/fix-flex-separator   # or look at GitHub
#   3. Replace PINNED_COMMIT below and commit.
#
# When upstream PR #411 lands and a release ships, delete this script and
# revert dot_claude/private_settings.json to `bunx -y ccstatusline@latest`.

set -euo pipefail

PINNED_COMMIT='bf46f92'

if ! command -v bun >/dev/null 2>&1; then
    echo "bun not on PATH — skipping ccstatusline fork install" >&2
    echo "  install bun (flox group: node) then re-run: chezmoi apply" >&2
    exit 0
fi

bun install --global "github:ssoriche/ccstatusline#${PINNED_COMMIT}"
