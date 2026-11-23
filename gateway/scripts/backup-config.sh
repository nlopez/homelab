#!/usr/bin/env bash
# Download each gateway's config.xml and upload it to the state bucket.
#
# Credentials come from the environment when set (CI), otherwise from 1Password
# (local runs). The AWS CLI supplies the bucket credentials.
set -euo pipefail

BUCKET="${BUCKET:-homelab-tofu-state-546422192262}"
VAULT="evjh25ux2mnoufaut6qhvm2pdi"
ACCOUNT="my.1password.com"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

read_secret() {
  local site="$1" field="$2" item="$3"
  local var="OPNSENSE_$(echo "$site" | tr '[:lower:]' '[:upper:]')_API_$(echo "$field" | tr '[:lower:]' '[:upper:]')"
  if [[ -n "${!var:-}" ]]; then
    printf '%s' "${!var}"
  else
    op read "op://${VAULT}/${item}/${field}" --account "$ACCOUNT"
  fi
}

backup() {
  local site="$1" item="$2"
  local key secret
  key="$(read_secret "$site" key "$item")"
  secret="$(read_secret "$site" credential "$item")"
  local dest="gateway-backups/${site}/${STAMP}.xml"

  curl -fsS -u "${key}:${secret}" \
    "https://gw.${site}.radoncanyon.com/api/core/backup/download/this" \
    -o "/tmp/${site}.xml"

  aws s3 cp "/tmp/${site}.xml" "s3://${BUCKET}/${dest}" --only-show-errors
  echo "${site}: s3://${BUCKET}/${dest}"
}

backup lga1 bf3fyn3ojaajnozdbobkhtboli
backup lga2 whuw4bp5c3lbzv2hmq4nja7qvq
