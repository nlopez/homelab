#!/usr/bin/env bash
# Resolves a stack's secrets.plan.env for a pull-request plan and exports each
# variable to the later steps of the job (GITHUB_ENV), masking every value in
# the log first. op:// references go through their own `op read`, with the
# read-only service account in OP_SERVICE_ACCOUNT_TOKEN; other values pass
# through unchanged. Lines that aren't NAME=value (comments, blanks) are skipped.
# Run by .github/workflows/_tofu-stack.yaml.
#
#   load-plan-credentials.sh <env file>
set -euo pipefail

file="${1:?usage: load-plan-credentials.sh <env file>}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"

while IFS='=' read -r name ref; do
  case "${ref}" in
    op://*) value="$(op read --no-newline "${ref}")" ;;
    *) value="${ref}" ;;
  esac
  while IFS= read -r line; do
    if [ -n "${line}" ]; then echo "::add-mask::${line}"; fi
  done <<<"${value}"
  delim="EOF_$(openssl rand -hex 8)"
  printf '%s<<%s\n%s\n%s\n' "${name}" "${delim}" "${value}" "${delim}" >>"${GITHUB_ENV}"
done < <(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "${file}")
