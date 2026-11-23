#!/usr/bin/env bash
# Keeps the Argo CD push webhook on this repository. Without it, Argo only
# notices a push when its poller runs, so apps lag behind main by up to three
# minutes. GitHub lets the hook be deleted from the UI, so this recreates it.
set -euo pipefail

repo=nlopez/homelab
url=https://flopie.desertbluffs.com/api/webhook
secret=$(op read "op://evjh25ux2mnoufaut6qhvm2pdi/4l6mpusylcw4swjrxoqlouu6xe/password")

body=$(printf '{"active":true,"events":["push"],"config":{"url":"%s","content_type":"json","secret":"%s","insecure_ssl":"0"}}' "$url" "$secret")
id=$(gh api "repos/$repo/hooks" --jq ".[] | select(.config.url == \"$url\") | .id")

if [ -n "$id" ]; then
  gh api -X PATCH "repos/$repo/hooks/$id" --input - <<<"$body" >/dev/null
  echo "updated hook $id"
else
  gh api -X POST "repos/$repo/hooks" --input - <<<"$body" >/dev/null
  echo "created hook"
fi
