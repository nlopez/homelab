#!/usr/bin/env bash
# After a push to main, fails ci-ok on every open pull request that changes a
# stack the push changed: their plans ran without it. ci-ok is otherwise only
# re-judged when the PR itself changes, and main doesn't require a PR to
# contain its latest commit. Run by .github/workflows/ci-gate-refresh.yaml with
# the ci-gate app's token.
#
# Needs GH_TOKEN (the app's), APP_ID, REPO, BEFORE and AFTER (the push), and
# RUN_URL.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

moved="$("${here}/stack-overlap.sh" changed "${BEFORE}" "${AFTER}")"
if [ -z "${moved}" ]; then
  echo "${AFTER:0:8} changes no stack."
  exit 0
fi
echo "${AFTER:0:8} changes: ${moved//$'\n'/, }"

open="$(gh api --paginate "repos/${REPO}/pulls?state=open&base=main&per_page=100" --jq '.[] | "\(.number)\t\(.head.sha)"')"
while IFS=$'\t' read -r number head; do
  [ -n "${number}" ] || continue
  theirs="$(gh api --paginate "repos/${REPO}/pulls/${number}/files?per_page=100" --jq '.[].filename' |
    "${here}/stack-overlap.sh" stacks)"
  common="$(comm -12 <(echo "${moved}") <(echo "${theirs}") | sed '/^$/d')"
  [ -n "${common}" ] || continue
  # The gate's own ci-ok run, changed in place, so the commit keeps one ci-ok.
  # With none yet, the gate's stale check sees this push when it runs.
  run="$(gh api "repos/${REPO}/commits/${head}/check-runs?check_name=ci-ok&app_id=${APP_ID}" \
    --jq '[.check_runs[]] | sort_by(.started_at) | last | .id // empty')"
  if [ -z "${run}" ]; then
    echo "#${number}: no ci-ok yet; its gate will see ${AFTER:0:8}."
    continue
  fi
  summary="main changed ${common//$'\n'/, } in ${AFTER:0:8}, so this PR's plans for them are stale. Rebase onto main and push; ci-ok runs again on the new commit."
  jq -n --arg url "${RUN_URL}" --arg s "${summary}" \
    '{status: "completed", conclusion: "failure", details_url: $url,
      output: {title: "main changed this PR'"'"'s stacks", summary: $s}}' |
    gh api -X PATCH "repos/${REPO}/check-runs/${run}" --input - >/dev/null
  echo "#${number}: failed ci-ok (${common//$'\n'/, })"
done <<<"${open}"
