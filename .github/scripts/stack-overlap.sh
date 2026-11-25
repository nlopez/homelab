#!/usr/bin/env bash
# Warns on pull requests that change the same stack as another open PR, so the
# agents (or people) behind them coordinate before one merge makes the other's
# plan stale. Run by .github/workflows/stack-overlap.yaml. Never fails a PR.
#
#   stack-overlap.sh stacks              # map paths on stdin to stack keys
#   stack-overlap.sh update <pr>         # refresh <pr>'s warning; print the PRs it overlaps
#   stack-overlap.sh update-all          # refresh every open PR's warning
#
# Needs REPO (owner/name) and GH_TOKEN. With DRY_RUN=1, prints comments
# instead of posting them.
set -euo pipefail

marker="<!-- stack-overlap -->"

# A stack is what one plan or one Argo CD Application covers: aws/<stack>,
# tailnet/admin, kubernetes/apps*/<app>, .github for the shared CI, and
# otherwise the top-level directory. Markdown and root files don't count.
stacks() {
  awk -F/ '
    /\.md$/ { next }
    NF == 1 { next }
    $1 == "aws" && NF > 2 { print "aws/" $2; next }
    $1 == "tailnet" && $2 == "admin" { print "tailnet/admin"; next }
    $1 == "kubernetes" && ($2 == "apps" || $2 == "apps-helm") && NF > 3 { print "kubernetes/" $2 "/" $3; next }
    { print $1 }
  ' | sort -u
}

pr_stacks() {
  gh api --paginate "repos/${REPO}/pulls/$1/files?per_page=100" --jq '.[].filename' | stacks
}

open_prs() {
  gh api --paginate "repos/${REPO}/pulls?state=open&per_page=100" --jq '.[] | "\(.number)\t\(.title)"'
}

post() { # <pr> <body file>
  local id
  id="$(gh api --paginate "repos/${REPO}/issues/$1/comments?per_page=100" \
    --jq ".[] | select(.user.login == \"github-actions[bot]\") | select(.body | startswith(\"${marker}\")) | .id" | tail -n 1)"
  if [ -z "${id}" ] && ! grep -q "^| " "$2"; then
    return 0 # No warning to post and none to retract.
  fi
  if [ "${DRY_RUN:-}" = 1 ]; then
    echo "--- #$1 ($([ -n "${id}" ] && echo "update ${id}" || echo new))"
    cat "$2"
  elif [ -n "${id}" ]; then
    gh api -X PATCH "repos/${REPO}/issues/comments/${id}" -F body=@"$2" >/dev/null
  else
    gh api -X POST "repos/${REPO}/issues/$1/comments" -F body=@"$2" >/dev/null
  fi
}

update() { # <pr>; prints the numbers of the PRs it overlaps
  local pr="$1" mine rows="" overlaps="" body
  mine="$(pr_stacks "${pr}")"
  while IFS=$'\t' read -r number title; do
    [ -n "${number}" ] && [ "${number}" != "${pr}" ] || continue
    common="$(comm -12 <(echo "${mine}") <(pr_stacks "${number}"))"
    [ -n "${common}" ] || continue
    overlaps+="${number}"$'\n'
    while read -r stack; do
      rows+="| \`${stack}\` | #${number} ${title//|/\\|} |"$'\n'
    done <<<"${common}"
  done < <(open_prs)

  body="$(mktemp)"
  {
    echo "${marker}"
    if [ -n "${rows}" ]; then
      echo "### ⚠️ Another open PR changes the same stack"
      echo
      echo "| Stack | Open PR |"
      echo "| --- | --- |"
      printf '%s' "${rows}"
      echo
      echo "Coordinate in one of the PRs before either merges. Whichever merges second must rebase and re-read its plans; a plan made before the other merge is stale (AGENTS.md)."
    else
      echo "No other open PR changes the same stacks any more."
    fi
  } > "${body}"
  post "${pr}" "${body}"
  rm -f "${body}"
  printf '%s' "${overlaps}"
}

case "${1:-}" in
  stacks) stacks ;;
  update) update "$2" ;;
  update-all) open_prs | cut -f1 | while read -r n; do update "${n}" >/dev/null; done ;;
  *) echo "usage: $0 stacks | update <pr> | update-all" >&2; exit 2 ;;
esac
