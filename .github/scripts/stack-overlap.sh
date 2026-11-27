#!/usr/bin/env bash
# Finds open pull requests that change the same stack as a given one, so the
# agents (or people) behind them coordinate before one merge makes the other's
# plan stale. The protected ci-ok gate (ci-gate-run.sh) puts the report in its
# summary comment. Only a warning: it never fails a PR.
#
#   stack-overlap.sh stacks              # map paths on stdin to stack keys
#   stack-overlap.sh report <pr>         # Markdown section for <pr>, or nothing
#   stack-overlap.sh stale <pr>          # stacks <pr> changes that main changed since it branched
#   stack-overlap.sh changed <from> <to> # stacks changed between two commits
#
# Needs REPO (owner/name) and GH_TOKEN for report, stale, and changed.
set -euo pipefail

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

report() { # <pr>
  local pr="$1" mine rows="" common open theirs
  mine="$(pr_stacks "${pr}")"
  [ -n "${mine}" ] || return 0
  # Into a variable first: a failure inside < <(...) would be ignored, and an
  # API error would read as "no overlap".
  open="$(gh api --paginate "repos/${REPO}/pulls?state=open&per_page=100" --jq '.[] | "\(.number)\t\(.title)"')"
  while IFS=$'\t' read -r number title; do
    if [ -z "${number}" ] || [ "${number}" = "${pr}" ]; then continue; fi
    theirs="$(pr_stacks "${number}")"
    common="$(comm -12 <(echo "${mine}") <(echo "${theirs}"))"
    [ -n "${common}" ] || continue
    while read -r stack; do
      rows+="| \`${stack}\` | #${number} ${title//|/\\|} |"$'\n'
    done <<<"${common}"
  done <<<"${open}"
  [ -n "${rows}" ] || return 0
  echo "**Another open PR changes the same stack:**"
  echo
  echo "| Stack | Open PR |"
  echo "| --- | --- |"
  printf '%s' "${rows}"
  echo
  echo "Coordinate in one of the PRs before either merges. Whichever merges second must rebase and re-read its plans; a plan made before the other merge is stale (AGENTS.md)."
}

changed() { # <from> <to>
  local files
  # Its caller runs it in $(...), where errexit doesn't apply: fail explicitly
  # so an API error never reads as "nothing changed".
  files="$(gh api --paginate "repos/${REPO}/compare/$1...$2" --jq '.files[]?.filename')" || return 1
  stacks <<<"${files}"
}

# A PR's plans are stale for a stack main changed after the PR branched: the
# plan ran without that change. main moving on other stacks leaves them valid.
stale() { # <pr>
  local pr="$1" head base mine moved
  head="$(gh api "repos/${REPO}/pulls/${pr}" --jq .head.sha)"
  base="$(gh api "repos/${REPO}/compare/main...${head}" --jq .merge_base_commit.sha)"
  if [ -z "${base}" ] || [ "${base}" = null ]; then
    echo "no merge base for #${pr}" >&2
    return 1
  fi
  mine="$(pr_stacks "${pr}")"
  moved="$(changed "${base}" main)"
  comm -12 <(echo "${mine}") <(echo "${moved}") | sed '/^$/d'
}

case "${1:-}" in
  stacks) stacks ;;
  report) report "$2" ;;
  stale) stale "$2" ;;
  changed) changed "$2" "$3" ;;
  *) echo "usage: $0 stacks | report <pr> | stale <pr> | changed <from> <to>" >&2; exit 2 ;;
esac
