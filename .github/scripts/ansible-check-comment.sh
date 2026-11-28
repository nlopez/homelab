#!/usr/bin/env bash
# Builds the pull-request comment for an `ansible-playbook --check --diff` run:
# the play recap and the diff, with a link to the job step that holds the full
# output. The repository is public and --diff output holds rendered templates,
# so every value of a variable named in the env file is replaced with *** first.
# Run by .github/workflows/ansible-check.yaml, with HEAD_SHA set to the pull
# request's head commit.
#
#   ansible-check-comment.sh <log> <env file> <outcome> <step url>
set -euo pipefail

log="${1:?usage: ansible-check-comment.sh <log> <env file> <outcome> <step url>}"
envfile="${2:?usage: ansible-check-comment.sh <log> <env file> <outcome> <step url>}"
outcome="${3:?usage: ansible-check-comment.sh <log> <env file> <outcome> <step url>}"
url="${4:?usage: ansible-check-comment.sh <log> <env file> <outcome> <step url>}"
: "${HEAD_SHA:?HEAD_SHA must be set}"

mapfile -t names < <(grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' "${envfile}" | tr -d '=')

# Longest values first, so a value that contains another is replaced whole.
redacted="$(perl -pe '
  BEGIN {
    @v = sort { length $b <=> length $a }
      grep { length } map { split /\n/, ($ENV{$_} // "") } @ARGV;
    @ARGV = ();
  }
  for my $s (@v) { s/\Q$s\E/***/g }
' "${names[@]}" <"${log}")"

recap="$(grep -E '^[A-Za-z0-9.-]+ +: ok=' <<<"${redacted}" || true)"

echo "<!-- ansible-diff -->"
echo "### Ansible check mode (${outcome}) on \`${HEAD_SHA:0:8}\`"
echo
if [ "${outcome}" != success ]; then
  echo "The check failed; see [the full output](${url})."
elif [ -n "${recap}" ] && ! grep -qE 'changed=[1-9]' <<<"${recap}"; then
  echo "No host would change. [Full output](${url})."
else
  echo "Hosts that would change are below. [Full output](${url})."
fi
echo
echo "Recap:"
echo
echo '```'
echo "${recap}"
echo '```'
echo
echo "Diff (secret values replaced with \`***\`):"
echo
echo '```diff'
tail -c 55000 <<<"${redacted}"
echo '```'
