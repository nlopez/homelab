#!/usr/bin/env bash
# Builds the one-comment summary of a pull request's checks, so a reviewer
# (person or agent) reads one table instead of a plan comment per stack.
# Run by ci-ok (.github/workflows/ci-gate.yaml).
#
#   ci-summary.sh <comments.json> <check-runs.json> <head sha> <gate outcome>
#
# comments.json is the PR's issue comments; check-runs.json is the head
# commit's check runs (both as JSON arrays). Prints the comment body.
set -euo pipefail

comments="$1" runs="$2" head="$3" gate="$4"

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

plans="$(jq -r --arg head "${head}" '
  [.[] | select(.body | startswith("<!-- tofu-plan: "))
   | (.body | split("\n")) as $l
   | {
       stack: ($l[0] | capture("<!-- tofu-plan: (?<s>.*) -->").s),
       fresh: (.body | contains("<!-- head: " + $head + " -->")),
       outcome: ($l | map(select(startswith("### "))) | first // "" | capture("\\((?<o>[a-z]+)\\)$").o // "unknown"),
       summary: ($l | map(select(startswith("Plan:") or startswith("No changes.")
                       or test("^(Plan: |No changes\\.)"))) | first // ""),
       destroys: (.body | contains("**Destroys or replaces:**")),
       url: .html_url
     }]
  | sort_by(.stack)
  | .[]
  | "| [\(.stack)](\(.url)) | \(if .fresh then
        (if .outcome != "success" then "❌ plan \(.outcome)"
         elif (.summary | startswith("No changes")) then "No changes"
         else (.summary | capture("Plan: (?<p>[^.]*)").p // .summary) end)
      else "⚪ not planned on this commit" end) | \(if .fresh and .destroys then "⚠️ yes" elif .fresh then "no" else "" end) |"
' "${comments}")"

if [ -n "${plans}" ]; then
  echo "| Stack | Plan | Destroys |"
  echo "| --- | --- | --- |"
  echo "${plans}"
  echo
  echo "Stacks marked not planned were planned on an earlier commit and this push didn't touch them."
else
  echo "No OpenTofu stack planned on this PR."
fi

diff="$(jq -r '[.[] | select(.body | startswith("<!-- manifest-diff -->"))] | last // empty
  | if (.body | contains("No changes found")) then "No changes" else "Changes; [read the diff](\(.html_url))" end' "${comments}")"
if [ -n "${diff}" ]; then
  echo
  echo "**Kubernetes manifest diff:** ${diff}"
fi
