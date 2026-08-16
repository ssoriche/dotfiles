#!/usr/bin/env bash
set -euo pipefail

# Turns the verdict flox-relock.sh's drift mode left in the workspace into a
# Forgejo issue, and closes that issue again once the lock is back in sync.
#
# This runs in a plain alpine image rather than the flox one on purpose: it needs
# curl and jq, and the flox CI image is a thin base that ships neither. Splitting
# the steps keeps the relock side free of any dependency it cannot count on --
# the same reasoning that removed jq from the PR check in e1ba6f7.

STATE=.flox-lock-drift-state

: "${FORGEJO_TOKEN:?FORGEJO_TOKEN is required}"
API="${CI_FORGE_URL:?}/api/v1/repos/${CI_REPO_OWNER:?}/${CI_REPO_NAME:?}"

# Defaulted rather than required: these only decorate the issue body, and losing
# the report because a context variable was renamed upstream would defeat the
# entire point of this script.
sha="${CI_COMMIT_SHA:-unknown}"
sha="${sha:0:8}"
branch="${CI_COMMIT_BRANCH:-main}"
log_url="${CI_PIPELINE_URL:-<pipeline url unavailable>}"

# The issue is identified by exact title match, not by label. A label would have
# to exist in the repo before it could be applied, which is one more thing to
# provision; the title is self-provisioning and stable.
TITLE="flox: manifest.lock is stale on main"

api() {
  local method="$1" path="$2"
  shift 2
  curl -sSf -X "$method" \
    -H "Authorization: token ${FORGEJO_TOKEN}" \
    -H "Content-Type: application/json" \
    "$@" "${API}${path}"
}

# Open issues only. A closed one from a previous incident must not suppress the
# report for a new one, and must not be reopened by the sync path either.
existing=$(api GET "/issues?state=open&type=issues&limit=50" \
  | jq --arg t "$TITLE" 'map(select(.title == $t)) | .[0].number // empty')

verdict=$(cat "$STATE" 2>/dev/null || echo missing)

case "$verdict" in
  sync)
    if [[ -z "$existing" ]]; then
      echo "Lock in sync, no open issue. Nothing to do."
      exit 0
    fi
    echo "Lock back in sync; closing issue #${existing}."
    jq -n --arg body "Lock is back in sync as of \`${sha}\`. Closed automatically by ${log_url}." \
      '{body: $body}' \
      | api POST "/issues/${existing}/comments" -d @- > /dev/null
    jq -n '{state: "closed"}' \
      | api PATCH "/issues/${existing}" -d @- > /dev/null
    ;;

  drift | error | missing)
    # `missing` means the drift step did not even get far enough to write a
    # verdict, which is as much a failure as a failed relock. Reported the same.
    if [[ -n "$existing" ]]; then
      # Deliberately no comment on the existing issue: this runs nightly and the
      # condition persists until someone acts, so commenting would only bury the
      # original report under identical notifications.
      echo "Already reported as issue #${existing}. Not commenting again."
      exit 0
    fi

    case "$verdict" in
      drift) detail="A relock of \`main\` produces a different \`manifest.lock\` than the one committed. The relock-on-push to main is not landing its commit." ;;
      error) detail="The relock itself failed. Most often this is a pinned version the Flox catalog cannot resolve yet, but read the log before concluding the pin is bad." ;;
      *)     detail="The drift check did not produce a verdict, so the relock step failed before it could write one." ;;
    esac

    echo "Opening a new issue."
    jq -n \
      --arg title "$TITLE" \
      --arg body "$(printf '%s\n\n%s\n\n%s\n\n%s\n' \
        "$detail" \
        "Checked at \`${sha}\` on \`${branch}\`." \
        "Log: ${log_url}" \
        "Worth checking first: that the \`forgejo_token\` secret still allows the \`push\` event. A pipeline that names a secret its event is not allowed to use fails to compile, which runs no steps and posts no commit status, so the relock stops silently. See \`.woodpecker/flox-relock.yaml\`.")" \
      '{title: $title, body: $body}' \
      | api POST "/issues" -d @- \
      | jq -r '"Opened issue #\(.number): \(.html_url)"'

    # Non-zero so the cron pipeline itself goes red too. The issue is the signal
    # meant to be noticed; this is the second one, for anyone looking at CI.
    exit 1
    ;;

  *)
    echo "Unrecognised verdict in ${STATE}: ${verdict}" >&2
    exit 2
    ;;
esac
