#!/usr/bin/env bash
# The ci-ok gate: waits until every other check on a pull request's head commit
# has finished, fails if any failed, and when a plan destroys or replaces
# anything, or the pull request changes the checks that report destroys,
# requires the destroy-approved label from a code owner, added by a
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
# The plan-destroys annotations come from the PR's own copy of these files, so
# a PR that changes them could hide a destroy. Changing them needs the same
# approval as a destroy.
detectors="$(gh api --paginate "repos/${REPO}/pulls/${PR}/files?per_page=100" \
  --jq '.[] | .filename, (.previous_filename // empty)' |
  grep -E '^\.github/(scripts/(plan-destroys|manifest-destroys|ci-gate-check)\.sh|actions/tofu-plan/|workflows/(_tofu-stack|kubernetes-argocd-diff|ci-gate-protected)\.yaml$)' |
  sort -u || true)"
if [ -n "${detectors}" ]; then
  while read -r file; do
    destroys+="${destroys:+$'\n'}Changes the destroy checks: ${file}"
  done <<<"${detectors}"
fi
if [ -z "${destroys}" ]; then
  echo "No plan destroys or replaces anything."
  exit 0
fi
echo "Destroys, replaces, or changes to the destroy checks:"
echo "${destroys}"

owners="$(gh api "repos/${REPO}/contents/.github/CODEOWNERS?ref=${BASE_REF}" --jq .content | base64 -d |
  awk '$1 == "*" { for (i = 2; i <= NF; i++) { sub(/^@/, "", $i); print $i } }')"
if ! gh api "repos/${REPO}/issues/${PR}/labels" --jq '.[].name' | grep -qx destroy-approved; then
  echo "::error::A plan destroys or replaces resources, or this PR changes the destroy checks. A code owner (${owners//$'\n'/, }) must review the plans and the change, then add the destroy-approved label."
  exit 1
fi
approval="$(gh api --paginate "repos/${REPO}/issues/${PR}/events?per_page=100" \
  --jq '.[] | select(.event == "labeled" and .label.name == "destroy-approved")
    | {actor: .actor.login, app: (.performed_via_github_app.slug // ""), at: .created_at}' | jq -s 'last')"
actor="$(jq -r .actor <<<"${approval}")"
app="$(jq -r .app <<<"${approval}")"
labeled_at="$(jq -r .at <<<"${approval}")"
# The approval covers only what the owner saw: a label added before the head
# commit was pushed (its first check suite) doesn't count.
pushed_at="$(gh api --paginate "repos/${REPO}/commits/${SHA}/check-suites?per_page=100" \
  --jq '.check_suites[].created_at' | sort | head -n 1)"
if [ -z "${pushed_at}" ] || [[ ! "${labeled_at}" > "${pushed_at}" ]]; then
  echo "::error::destroy-approved was added at ${labeled_at}, before ${SHA:0:8} was pushed at ${pushed_at:-an unknown time}. A code owner must review this commit, then remove the label and add it again."
  exit 1
fi
if [ -n "${app}" ]; then
  echo "::error::destroy-approved was added through the ${app} app, not by a person. A code owner must add it by hand."
  exit 1
fi
if ! grep -qx "${actor}" <<<"${owners}"; then
  echo "::error::destroy-approved was added by ${actor}, who is not a code owner (${owners//$'\n'/, })."
  exit 1
fi
echo "${actor} approved the destroys and replaces."
