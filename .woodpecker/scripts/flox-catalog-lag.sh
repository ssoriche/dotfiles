#!/usr/bin/env bash
set -euo pipefail

# Keeps each dual-catalog package sourced from whichever catalog currently
# tracks upstream faster.
#
# claude-code and herdr exist in both the nixpkgs catalog (bare pkg-path) and
# the flox catalog (flox/ prefix), and which side runs ahead flips over time --
# claude-code went nixpkgs->flox (fb631e8), back (7999947), and back again. The
# lagging side is never broken, only stale, but stale is a real cost: nixpkgs'
# claude-code 2.1.245 shipped without model access that flox's 2.1.258 had.
#
# detect -- query both catalogs per package, print the verdict, change nothing.
#           Safe to run locally; needs only curl and jq.
# apply  -- detect, then act: when a package's other catalog is strictly ahead,
#           push a one-commit branch flipping its pkg-path + pin and open a
#           Forgejo PR; when nothing lags and a flip PR is still open, close it
#           as overtaken. Run on cron.
#
# The flip touches only manifest.toml. renovate.json needs no edit because its
# dedicated dual-catalog manager captures packageName from the pkg-path line,
# and the lock is never written here: flox-relock.yaml's pull_request check
# proves the flipped pins resolve before merge, and its push-to-main step
# regenerates the lock after.

mode="${1:?usage: flox-catalog-lag.sh <detect|apply>}"

MANIFEST=dot_flox/env/private_manifest.toml
BRANCH=flox-catalog-flip
CATALOG_API=https://api.flox.dev/api/v1/catalog/packages

# The dual-catalog packages. A member must also be listed in renovate.json's
# dedicated dual-catalog manager (both its key alternation and the disabling
# packageRule), or a flip strands its pin on the wrong catalog's version feed.
PACKAGES=(claude-code herdr)

# Keep in sync with [options].systems in the manifest and the transform in
# renovate.json's flox-catalog datasource: a version only counts when every
# system can resolve it, or a flip could write a pin one system cannot lock.
SYSTEMS='["aarch64-darwin", "aarch64-linux", "x86_64-linux"]'

# Newest stable version the named catalog entry offers on every system; empty
# when there is none. Prereleases are excluded, mirroring Renovate's default
# semver behaviour, and the same guard restricts the compare below to numeric
# triples so jq's array comparison orders them correctly.
best_version() {
  curl -sSf "${CATALOG_API}/${1}?pageSize=200" | jq -r --argjson sys "$SYSTEMS" '
    [ .items[] | select([.system] | inside($sys)) ]
    | group_by(.version)
    | map(select([.[].system] | unique | length == ($sys | length)))
    | map(.[0].version)
    | map(select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$")))
    | map(split(".") | map(tonumber))
    | sort | last
    | if . == null then empty else map(tostring) | join(".") end'
}

# True when $1 is strictly newer than $2. Both are numeric triples by
# construction, so jq array comparison is exact -- no sort -V, which busybox
# coreutils does not promise.
newer() {
  jq -en --arg a "$1" --arg b "$2" \
    '($a | split(".") | map(tonumber)) > ($b | split(".") | map(tonumber))' \
    > /dev/null
}

flips=() # "<pkg> <target pkg-path> <target version>"
for pkg in "${PACKAGES[@]}"; do
  cur_path=$(sed -n "s/^${pkg}\.pkg-path = \"\(.*\)\"\$/\1/p" "$MANIFEST")
  if [[ -z "$cur_path" ]]; then
    echo "WARNING: no pkg-path for ${pkg} in ${MANIFEST}; dropped from the manifest but not from PACKAGES?" >&2
    continue
  fi
  if [[ "$cur_path" == "flox/${pkg}" ]]; then
    other_path="$pkg"
  else
    other_path="flox/${pkg}"
  fi

  best_cur=$(best_version "$cur_path")
  best_other=$(best_version "$other_path")
  echo "${pkg}: on ${cur_path}@${best_cur:-none}; other side ${other_path}@${best_other:-none}"

  # No all-systems version on the other side means nothing to flip to; none on
  # the current side (a package pulled from a catalog, say) means any version
  # on the other side wins.
  [[ -n "$best_other" ]] || continue
  if [[ -z "$best_cur" ]] || newer "$best_other" "$best_cur"; then
    flips+=("${pkg} ${other_path} ${best_other}")
  fi
done

if [[ "$mode" == "detect" ]]; then
  if ((${#flips[@]})); then
    printf 'Would flip: %s\n' "${flips[@]}"
  else
    echo "Every dual-catalog package is already on the faster catalog."
  fi
  exit 0
fi

if [[ "$mode" != "apply" ]]; then
  echo "unknown mode: $mode (expected 'detect' or 'apply')" >&2
  exit 2
fi

: "${FORGEJO_TOKEN:?FORGEJO_TOKEN is required}"
API="${CI_FORGE_URL:?}/api/v1/repos/${CI_REPO_OWNER:?}/${CI_REPO_NAME:?}"
remote="https://woodpecker-ci:${FORGEJO_TOKEN}@${CI_FORGE_URL#https://}/${CI_REPO_OWNER}/${CI_REPO_NAME}.git"

api() {
  local method="$1" path="$2"
  shift 2
  curl -sSf -X "$method" \
    -H "Authorization: token ${FORGEJO_TOKEN}" \
    -H "Content-Type: application/json" \
    "$@" "${API}${path}"
}

existing_pr=$(api GET "/pulls?state=open&limit=50" \
  | jq -r --arg b "$BRANCH" 'map(select(.head.ref == $b)) | .[0].number // empty')

if ((${#flips[@]} == 0)); then
  if [[ -n "$existing_pr" ]]; then
    # The lagging catalog caught up (or overtook) before the flip merged, so the
    # flip is moot. Close rather than leave a stale PR that would flip onto what
    # is now the slower side.
    echo "No lag, but flip PR #${existing_pr} is still open; closing as overtaken."
    jq -n '{body: "The lagging catalog caught up before this merged, so the flip is moot. Closed automatically by the flox-catalog-lag watchdog."}' \
      | api POST "/issues/${existing_pr}/comments" -d @- > /dev/null
    jq -n '{state: "closed"}' \
      | api PATCH "/pulls/${existing_pr}" -d @- > /dev/null
    api DELETE "/branches/${BRANCH}" > /dev/null || true
  else
    echo "Nothing to do."
  fi
  exit 0
fi

git config user.name "woodpecker-ci"
# Deliberately NOT the relock bot's exact address: flox-relock.yaml's not_bot
# guard filters woodpecker-ci@noreply.git.s8i.app by string equality, and this
# PR needs that pipeline to run twice -- the pull_request check to prove the
# flipped pins resolve, and the push-to-main relock after merge.
git config user.email "woodpecker-ci+catalog@noreply.git.s8i.app"
# The alpine image carries no signing config, but anyone reproducing this
# locally inherits ~/.gitconfig's signing setup; a bot commit stays unsigned.
git config commit.gpgsign false

summary=""
for flip in "${flips[@]}"; do
  read -r pkg target_path target_ver <<< "$flip"
  sed -i "s|^${pkg}\.pkg-path = .*|${pkg}.pkg-path = \"${target_path}\"|" "$MANIFEST"
  sed -i "s|^${pkg}\.version = .*|${pkg}.version = \"${target_ver}\"|" "$MANIFEST"
  [[ "$target_path" == flox/* ]] && label=flox || label=nixpkgs
  summary+="${pkg} -> ${label} catalog (${target_ver})"$'\n'
done

if ((${#flips[@]} == 1)); then
  read -r pkg target_path target_ver <<< "${flips[0]}"
  [[ "$target_path" == flox/* ]] && label=flox || label=nixpkgs
  msg="feat(flox): switch ${pkg} to ${label} catalog (${target_ver})"
else
  msg="feat(flox): switch lagging packages to their faster catalogs"$'\n\n'"${summary}"
fi

git checkout -B "$BRANCH"
git add "$MANIFEST"
git commit -m "$msg"

# Idempotence across nightly runs: only force-push when the flip content
# actually changed, so an untouched open PR is not churned every night.
if git fetch "$remote" "refs/heads/${BRANCH}" 2>/dev/null \
  && [[ "$(git rev-parse 'HEAD^{tree}')" == "$(git rev-parse 'FETCH_HEAD^{tree}')" ]]; then
  echo "Branch ${BRANCH} already carries this exact flip."
else
  git push -f "$remote" "HEAD:refs/heads/${BRANCH}"
fi

if [[ -n "$existing_pr" ]]; then
  echo "Flip PR #${existing_pr} already open; branch updated where needed."
  exit 0
fi

body="The catalog these packages are pinned from has fallen behind its counterpart:

${summary}
This PR flips \`pkg-path\` (and the pin) to the faster side. Nothing else needs to change: Renovate's dual-catalog manager follows \`pkg-path\`, the \`flox-relock\` check on this PR proves the new pins resolve on every system, and the lock is regenerated on main after merge.

Opened automatically by the flox-catalog-lag watchdog (\`.woodpecker/flox-catalog-lag.yaml\`)."

jq -n --arg title "$msg" --arg head "$BRANCH" --arg body "$body" \
  '{title: ($title | split("\n")[0]), head: $head, base: "main", body: $body}' \
  | api POST "/pulls" -d @- \
  | jq -r '"Opened PR #\(.number): \(.html_url)"'
