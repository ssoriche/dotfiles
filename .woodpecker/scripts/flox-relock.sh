#!/usr/bin/env bash
set -euo pipefail

git config --global --add safe.directory "$(pwd)"

# Reconstruct the .flox/ layout Flox expects from the chezmoi source
# encoding (dot_flox/... -> .flox/..., private_manifest.* -> manifest.*).
# Do NOT use `chezmoi apply` here: it runs unrelated run_once_/run_onchange_
# scripts and external clones that have nothing to do with Flox.
mkdir -p .flox/env
cp dot_flox/env.json .flox/env.json
cp dot_flox/env/private_manifest.toml .flox/env/manifest.toml
cp dot_flox/env/private_manifest.lock .flox/env/manifest.lock

# Re-resolve. Exits non-zero if a pinned version isn't resolvable yet in
# Flox's catalog -- that failure is the intended CI gate.
flox activate -d . -c "true"

cp .flox/env/manifest.lock dot_flox/env/private_manifest.lock

if git diff --quiet -- dot_flox/env/private_manifest.lock; then
  echo "Lockfile unchanged, nothing to push."
  exit 0
fi

git config user.name "woodpecker-ci"
git config user.email "woodpecker-ci@noreply.git.s8i.app"
git add dot_flox/env/private_manifest.lock
git commit -m "chore(flox): regenerate manifest.lock"
git push "https://woodpecker-ci:${FORGEJO_TOKEN}@git.s8i.app/shawn/dotfiles.git" "HEAD:${CI_COMMIT_SOURCE_BRANCH}"
