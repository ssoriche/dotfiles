#!/usr/bin/env bash
set -euo pipefail

# check  -- relock and report, without committing. Run on pull_request. A lock
#           diff is expected here and is not a failure: the lock is deliberately
#           no longer committed to the PR branch. Uses lock_only.
# commit -- relock and land the regenerated lock. Run on push to main. Uses
#           relock_and_build, so main also gets the buildability check that the
#           PR deliberately skips.
mode="${1:?usage: flox-relock.sh <check|commit>}"

git config --global --add safe.directory "$(pwd)"

MANIFEST=dot_flox/env/private_manifest.toml
LOCK=dot_flox/env/private_manifest.lock

# Both paths below resolve every system the manifest declares -- aarch64-darwin,
# aarch64-linux, and x86_64-linux (macOS-only packages are isolated with
# per-package `systems` overrides). Flox catalog resolution is metadata-only,
# not tied to the host actually executing each system's binaries, so resolving
# on this Linux CI runner correctly covers aarch64-darwin too -- verified
# directly: bumping a package's pin and relocking from Linux updated all three
# systems' entries with no loss or corruption of the darwin entry.

# Resolution only; never touches the Nix store. Sub-second, against 3-7 minutes
# for relock_and_build, because the entire cost of `flox activate` is realising
# the environment rather than resolving it -- both resolve incrementally against
# the seed lock and rewrite only the changed pin.
#
# Verified equivalent to the activate path in content: both resolve every
# package to the same version and rev, and both exit non-zero with the same
# per-system error when a pin is missing from the catalog. They do NOT agree on
# the order of the `packages` array, so the two locks are not byte-comparable.
# That is why commit mode must keep using relock_and_build: the lock committed to
# main has to stay in the order a local `flox activate` would write it, or every
# apply would reorder it back and leave chezmoi showing permanent drift.
#
# `lock-manifest` is absent from `flox --help` in 1.13.1 but present and
# documented under `--help` on the subcommand itself. If a future flox drops it,
# fall back to relock_and_build here.
lock_only() {
  # A fixed sibling path rather than mktemp: the flox CI image is a thin base and
  # every external command here is a chance to fail the way jq did, so this
  # function is deliberately limited to flox plus shell builtins and mv.
  local tmp="${LOCK}.new"
  # Seeded with the current lock so only changed pins are re-resolved.
  flox lock-manifest -l "$LOCK" "$MANIFEST" > "$tmp"
  # `flox activate` terminates the lock with a newline; stdout does not.
  # Without this every relock on main would churn that one byte.
  printf '\n' >> "$tmp"
  mv "$tmp" "$LOCK"
}

# Resolves AND realises the environment for the runner's own system, building or
# substituting every package. A non-zero exit means one of:
#
#   1. A pinned version is not in the Flox catalog yet -- Renovate can outrun the
#      catalog snapshots. lock_only catches this too, on the PR.
#   2. The version resolves but no substituter can supply a build for this
#      system. Only this path catches that, which is why main still runs it.
#   3. The runner's Nix store is corrupt. Seen on pipeline 47, where a path was
#      present on disk but unregistered in the store DB; a plain rerun (48)
#      passed on the identical commit.
#
# Only case 1 says anything about the change under test. Read the log before
# concluding that a red run means the bump itself is bad.
relock_and_build() {
  mkdir -p .flox/env
  cp dot_flox/env.json .flox/env.json
  cp "$MANIFEST" .flox/env/manifest.toml
  cp "$LOCK" .flox/env/manifest.lock

  flox activate -d . -c "true"

  cp .flox/env/manifest.lock "$LOCK"
}

if [[ "$mode" == "check" ]]; then
  # No diff of the regenerated lock is reported. lock_only and relock_and_build
  # order the `packages` array differently, so a plain `git diff` is ~90 lines of
  # churn on every PR regardless of what changed, and comparing them
  # order-independently needs a JSON parser. The flox CI image ships neither jq
  # nor any guarantee of sed/sort/diff, so the informational report is not worth
  # a dependency the image may not have -- the gate is lock_only's exit code,
  # and Renovate's own manifest diff already shows which pin moved.
  lock_only
  echo "Every pin resolves. The lock will be regenerated on main after merge."
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
  relock_and_build

  if git diff --quiet -- "$LOCK"; then
    echo "Lockfile already in sync, nothing to push."
    exit 0
  fi

  git add "$LOCK"
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
