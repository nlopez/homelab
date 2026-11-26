#!/usr/bin/env bash
# Builds the one-comment summary of a pull request's checks, so a reviewer
# (person or agent) reads one table instead of each stack's plan.
# Run by the protected ci-ok gate (.github/workflows/ci-gate-protected.yaml).
#
#   ci-summary.sh <runs.json> <annotations.json> <comments.json> <head sha> <gate outcome>
#
# runs.json: the head commit's check runs. annotations.json: the plan-result
# and plan-destroys annotations of those runs, as [{check, url, title,
# message}]; each plan job adds them (.github/actions/tofu-plan). Since both
# belong to the head commit, every row is this push's plan. comments.json: the
# PR's bot comments, for the Kubernetes manifest diff. Prints the comment body.
set -euo pipefail

runs="$1" annotations="$2" comments="$3" head="$4" gate="$5"

echo "<!-- ci-summary -->"
case "${gate}" in
  success) echo "### ✅ ci-ok passed on \`${head:0:8}\`" ;;
  *) echo "### ❌ ci-ok ${gate} on \`${head:0:8}\`" ;;
esac
echo

failed="$(jq -r '.[] | select(.name != "ci-ok" and .status == "completed")
  | select(.conclusion | IN("success", "skipped", "neutral") | not)
  | "- `\(.name)`: \(.conclusion)"' "${runs}")"
pending="$(jq -r '.[] | select(.name != "ci-ok" and .status != "completed") | "- `\(.name)`: \(.status)"' "${runs}")"
if [ -n "${failed}${pending}" ]; then
  echo "**Checks not passing:**"
  echo
  [ -n "${failed}" ] && echo "${failed}"
  [ -n "${pending}" ] && echo "${pending}"
  echo
fi

plans="$(jq -r '
  (map(select(.title == "plan-destroys") | .check) | unique) as $destroying
  | [.[] | select(.title == "plan-result")
     | (.message | fromjson) as $r
     | {stack: $r.stack, outcome: $r.outcome, summary: $r.summary, url, destroys: (.check | IN($destroying[]))}]
  | sort_by(.stack)
  | .[]
  | "| [\(.stack)](\(.url)) | \(
        if .outcome != "success" then "❌ plan \(.outcome)"
        elif (.summary | startswith("No changes")) then "No changes"
        else (.summary | capture("Plan: (?<p>[^.]*)").p // .summary) end) | \(if .destroys then "⚠️ yes" else "no" end) |"
' "${annotations}")"

if [ -n "${plans}" ]; then
  echo "| Stack | Plan | Destroys |"
  echo "| --- | --- | --- |"
  echo "${plans}"
  echo
  echo "Each stack links to its plan job; the full plan is in that job's summary."
else
  echo "No OpenTofu stack planned on this commit."
fi

diff="$(jq -r '[.[] | select(.body | startswith("<!-- manifest-diff -->"))] | last // empty
  | if (.body | contains("No changes found")) then "No changes" else "Changes; [read the diff](\(.html_url))" end' "${comments}")"
if [ -n "${diff}" ]; then
  echo
  echo "**Kubernetes manifest diff:** ${diff}"
fi
