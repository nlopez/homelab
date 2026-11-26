#!/usr/bin/env bash
# Mints a GitHub App's credentials with openssl, curl, and jq instead of a
# third-party action, for the protected ci-ok gate.
#
#   app-token.sh jwt <app id> <private key file>          # a 10-minute app JWT
#   app-token.sh token <app id> <private key file> <owner/repo>
#                                                         # an installation token for the repo
#
# GITHUB_API_URL overrides https://api.github.com.
set -euo pipefail

api_url="${GITHUB_API_URL:-https://api.github.com}"

b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

jwt() { # <app id> <key file>
  local now header payload signature
  now="$(date +%s)"
  header="$(printf '{"alg":"RS256","typ":"JWT"}' | b64url)"
  # Backdated a minute for clock drift; GitHub accepts at most ten minutes.
  payload="$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$((now - 60))" "$((now + 540))" "$1" | b64url)"
  signature="$(printf '%s.%s' "${header}" "${payload}" | openssl dgst -sha256 -sign "$2" -binary | b64url)"
  printf '%s.%s.%s\n' "${header}" "${payload}" "${signature}"
}

case "${1:-}" in
  jwt)
    jwt "${2:?app id}" "${3:?private key file}"
    ;;
  token)
    token="$(jwt "${2:?app id}" "${3:?private key file}")"
    repo="${4:?owner/repo}"
    call() { curl -fsS -H "Authorization: Bearer ${token}" -H "Accept: application/vnd.github+json" "$@"; }
    installation="$(call "${api_url}/repos/${repo}/installation" | jq -r .id)"
    call -X POST "${api_url}/app/installations/${installation}/access_tokens" | jq -r .token
    ;;
  *)
    echo "usage: app-token.sh jwt <app id> <key file> | token <app id> <key file> <owner/repo>" >&2
    exit 2
    ;;
esac
