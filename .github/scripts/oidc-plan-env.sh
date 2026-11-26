#!/usr/bin/env bash
# Sets plan variables to GitHub Actions OIDC tokens, for stacks whose API
# accepts this repository's token in place of a key (arr: the sonarr-api-ci and
# radarr-api-ci routes). Each line of stdin is NAME=audience; the token for that
# audience is masked and exported to the later steps of the job (GITHUB_ENV).
# Lines that aren't NAME=value are skipped. Needs id-token: write.
# Run by .github/workflows/_tofu-stack.yaml.
#
#   oidc-plan-env.sh <<<"TF_VAR_sonarr_api_key=jolthog.desertbluffs.com"
set -euo pipefail

: "${GITHUB_ENV:?GITHUB_ENV must be set}"
: "${ACTIONS_ID_TOKEN_REQUEST_URL:?needs id-token: write}"
: "${ACTIONS_ID_TOKEN_REQUEST_TOKEN:?needs id-token: write}"

while IFS='=' read -r name audience; do
  token="$(curl -fsS -H "Authorization: Bearer ${ACTIONS_ID_TOKEN_REQUEST_TOKEN}" \
    --get --data-urlencode "audience=${audience}" "${ACTIONS_ID_TOKEN_REQUEST_URL}" | jq -er .value)"
  echo "::add-mask::${token}"
  printf '%s=%s\n' "${name}" "${token}" >>"${GITHUB_ENV}"
done < <(grep -E '^[A-Za-z_][A-Za-z0-9_]*=.' || true)
