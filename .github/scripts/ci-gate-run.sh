#!/usr/bin/env bash
# The protected ci-ok gate, end to end: creates the app's in_progress ci-ok
# check run, runs ci-gate-check.sh, posts or updates the PR's summary comment,
# and completes ci-ok with the gate's result. Exits with the gate's status, so
# the job fails when the gate does. Run by
# .github/workflows/ci-gate-protected.yaml with the ci-gate app's token.
#
# Needs GH_TOKEN (the app's), REPO, SHA, PR, BASE_REF and RUN_URL. Writes
# CHECK_RUN_ID to GITHUB_ENV when set, so a cancelled job can still complete
# the check run.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
app_login="${APP_LOGIN:-nlopez-homelab-ci-gate[bot]}"
work="$(mktemp -d)"
trap 'rm -rf "${work}"' EXIT

check_run="$(gh api -X POST "repos/${REPO}/check-runs" -f name=ci-ok -f head_sha="${SHA}" \
  -f status=in_progress -f details_url="${RUN_URL}" --jq .id)"
if [ -n "${GITHUB_ENV:-}" ]; then echo "CHECK_RUN_ID=${check_run}" >> "${GITHUB_ENV}"; fi

# No pipe: the gate's own exit status is the result.
status=0
"${here}/ci-gate-check.sh" > "${work}/gate.log" 2>&1 || status=$?
cat "${work}/gate.log"
if [ "${status}" -eq 0 ]; then gate=success; else gate=failure; fi

# One comment per PR, updated on every run, summing up every check and plan.
gh api --paginate "repos/${REPO}/issues/${PR}/comments?per_page=100" \
  --jq '.[] | select(.user.type == "Bot")' | jq -s . > "${work}/comments.json"
gh api --paginate "repos/${REPO}/commits/${SHA}/check-runs?per_page=100" \
  --jq '.check_runs[]' | jq -s . > "${work}/runs.json"
jq -r '.[] | select(.name != "ci-ok" and .name != "Protected gate" and .output.annotations_count > 0)
  | "\(.id)\t\(.name)\t\(.html_url)"' "${work}/runs.json" |
  while IFS=$'\t' read -r id name url; do
    gh api --paginate "repos/${REPO}/check-runs/${id}/annotations?per_page=100" \
      --jq ".[] | select(.title == \"plan-result\" or .title == \"plan-destroys\")
        | {check: \"${name}\", url: \"${url}\", title, message}"
  done | jq -s . > "${work}/annotations.json"
"${here}/ci-summary.sh" "${work}/runs.json" "${work}/annotations.json" "${work}/comments.json" \
  "${SHA}" "${gate}" > "${work}/summary.md"
# Overlap with other open PRs is advisory: a failure to work it out says so
# instead of failing the gate.
if overlap="$("${here}/stack-overlap.sh" report "${PR}" 2>"${work}/overlap.err")"; then
  if [ -n "${overlap}" ]; then printf '\n%s\n' "${overlap}" >> "${work}/summary.md"; fi
else
  printf '\n_Couldn'"'"'t check other open PRs for the same stacks: %s_\n' "$(tail -n 1 "${work}/overlap.err")" >> "${work}/summary.md"
fi
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then cat "${work}/summary.md" >> "${GITHUB_STEP_SUMMARY}"; fi
comment="$(jq -r --arg login "${app_login}" '[.[] | select(.user.login == $login)
  | select(.body | startswith("<!-- ci-summary -->"))] | last | .id // empty' "${work}/comments.json")"
if [ -n "${comment}" ]; then
  gh api -X PATCH "repos/${REPO}/issues/comments/${comment}" -F body=@"${work}/summary.md" >/dev/null
else
  gh api -X POST "repos/${REPO}/issues/${PR}/comments" -F body=@"${work}/summary.md" >/dev/null
fi

if [ "${gate}" = success ]; then title="Every other check passed"; else title="The gate failed"; fi
jq -n --arg c "${gate}" --arg t "${title}" --rawfile s <(tail -c 60000 "${work}/gate.log") \
  '{status: "completed", conclusion: $c, output: {title: $t, summary: ("```\n" + $s + "\n```")}}' |
  gh api -X PATCH "repos/${REPO}/check-runs/${check_run}" --input - >/dev/null
exit "${status}"
