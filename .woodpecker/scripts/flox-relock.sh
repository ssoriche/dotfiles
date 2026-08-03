#!/usr/bin/env bash
set -euo pipefail

# check  -- re-resolve only, to prove the pinned versions exist in the catalog.
#           Run on pull_request. A lock diff is expected here and is not a
#           failure: the lock is deliberately no longer committed to the PR
#           branch. The gate is `flox activate` itself exiting non-zero.
# commit -- re-resolve and land the regenerated lock. Run on push to main.
mode="${1:?usage: flox-relock.sh <check|commit>}"

git config --global --add safe.directory "$(pwd)"

# The dotfiles environment declares aarch64-darwin, aarch64-linux, and
# x86_64-linux (macOS-only packages are isolated with per-package `systems`
# overrides). Flox catalog resolution is metadata-only, not tied to the host
# actually executing each system's binaries, so activating on this Linux CI
# runner correctly re-resolves every declared system in the shared lock,
# including aarch64-darwin -- verified directly: bumping a package's pin and
# relocking from Linux updated all three systems' entries with no loss or
# corruption of the darwin entry.
relock() {
  mkdir -p .flox/env
  cp dot_flox/env.json .flox/env.json
  cp dot_flox/env/private_manifest.toml .flox/env/manifest.toml
  cp dot_flox/env/private_manifest.lock .flox/env/manifest.lock

  # Exits non-zero if a pinned version isn't resolvable yet in Flox's catalog.
  flox activate -d . -c "true"

  cp .flox/env/manifest.lock dot_flox/env/private_manifest.lock
}

if [[ "$mode" == "check" ]]; then
  relock
  if git diff --quiet -- dot_flox/env/private_manifest.lock; then
    echo "Every pin resolves; lock already in sync."
  else
    echo "Every pin resolves. The lock below will be regenerated on main after merge:"
    git --no-pager diff --stat -- dot_flox/env/private_manifest.lock
  fi
  exit 0
fi

if [[ "$mode" != "commit" ]]; then
  echo "unknown mode: $mode (expected 'check' or 'commit')" >&2
  exit 2
fi

git config user.name "woodpecker-ci"
git config user.email "woodpecker-ci@noreply.git.s8i.app"
# The flox image carries no signing config, but a developer reproducing this
# locally inherits ~/.gitconfig's `commit.gpgsign = true` and the commit then
# dies on the 1Password agent. A bot commit has no business being signed.
git config commit.gpgsign false

remote="https://woodpecker-ci:${FORGEJO_TOKEN}@git.s8i.app/shawn/dotfiles.git"

# A second merge can land on main while we are resolving, which rejects our
# push. Rebasing the lock commit would be wrong -- the lock we just built is
# stale against the newer manifest.toml -- so reset to the new tip and redo the
# whole relock against it.
for attempt in 1 2 3; do
  relock

  if git diff --quiet -- dot_flox/env/private_manifest.lock; then
    echo "Lockfile already in sync, nothing to push."
    exit 0
  fi

  git add dot_flox/env/private_manifest.lock
  git commit -m "chore(flox): regenerate manifest.lock"

  if git push "$remote" "HEAD:${CI_COMMIT_BRANCH}"; then
    exit 0
  fi

  echo "Push rejected on attempt ${attempt}; ${CI_COMMIT_BRANCH} moved. Redoing relock against the new tip."
  git fetch "$remote" "${CI_COMMIT_BRANCH}"
  git reset --hard FETCH_HEAD
done

echo "Could not land the regenerated lock after 3 attempts." >&2
exit 1
