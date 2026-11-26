#!/usr/bin/env bash
# The ci-ok gate: waits until every other check on a pull request's head commit
# has finished, fails if any failed, and when a plan destroys or replaces
# anything, requires the destroy-approved label from a code owner, added by a
# person rather than through an app. Run by .github/workflows/ci-gate-protected.yaml
# (main's copy, on pull_request_target, so a PR can't change what judges it).
#
# Needs GH_TOKEN, REPO (owner/name), SHA (the PR's head commit), PR (number),
# and BASE_REF (the PR's base branch).
set -euo pipefail
# Give the other workflows of this push time to register their runs.
sleep "${GATE_SETTLE:-30}"
quiet=0
while :; do
  runs="$(gh api --paginate "repos/${REPO}/commits/${SHA}/check-runs?per_page=100" \
    --jq '.check_runs[] | select(.name != "ci-ok" and .name != "Protected gate") | {name, status, conclusion}' | jq -s .)"
  failed="$(jq -r '.[] | select(.status == "completed")
    | select(.conclusion | IN("success", "skipped", "neutral") | not)
    | "\(.name): \(.conclusion)"' <<<"${runs}")"
  if [ -n "${failed}" ]; then
    echo "::error::Checks failed on ${SHA:0:8}:"
    echo "${failed}"
    exit 1
  fi
  pending="$(jq '[.[] | select(.status != "completed")] | length' <<<"${runs}")"
  if [ "${pending}" -eq 0 ]; then
    # Two quiet polls in a row, so a workflow that starts late still counts.
    quiet=$((quiet + 1))
    [ "${quiet}" -ge 2 ] && break
  else
    quiet=0
  fi
  sleep "${GATE_POLL:-20}"
done
echo "All other checks passed on ${SHA:0:8}:"
jq -r '.[] | "\(.name): \(.conclusion)"' <<<"${runs}"

destroys="$(gh api --paginate "repos/${REPO}/commits/${SHA}/check-runs?per_page=100" \
  --jq '.check_runs[] | select(.name != "ci-ok" and .name != "Protected gate" and .output.annotations_count > 0) | .id' |
  while read -r id; do
    gh api --paginate "repos/${REPO}/check-runs/${id}/annotations?per_page=100" \
      --jq '.[] | select(.title == "plan-destroys") | .message'
  done)"
if [ -z "${destroys}" ]; then
  echo "No plan destroys or replaces anything."
  exit 0
fi
echo "Plans that destroy or replace resources:"
echo "${destroys}"

owners="$(gh api "repos/${REPO}/contents/.github/CODEOWNERS?ref=${BASE_REF}" --jq .content | base64 -d |
  awk '$1 == "*" { for (i = 2; i <= NF; i++) { sub(/^@/, "", $i); print $i } }')"
if ! gh api "repos/${REPO}/issues/${PR}/labels" --jq '.[].name' | grep -qx destroy-approved; then
  echo "::error::A plan destroys or replaces resources. A code owner (${owners//$'\n'/, }) must review the plan comments and add the destroy-approved label."
  exit 1
fi
approval="$(gh api --paginate "repos/${REPO}/issues/${PR}/events?per_page=100" \
  --jq '.[] | select(.event == "labeled" and .label.name == "destroy-approved")
    | {actor: .actor.login, app: (.performed_via_github_app.slug // "")}' | jq -s 'last')"
actor="$(jq -r .actor <<<"${approval}")"
app="$(jq -r .app <<<"${approval}")"
if [ -n "${app}" ]; then
  echo "::error::destroy-approved was added through the ${app} app, not by a person. A code owner must add it by hand."
  exit 1
fi
if ! grep -qx "${actor}" <<<"${owners}"; then
  echo "::error::destroy-approved was added by ${actor}, who is not a code owner (${owners//$'\n'/, })."
  exit 1
fi
echo "${actor} approved the destroys and replaces."

