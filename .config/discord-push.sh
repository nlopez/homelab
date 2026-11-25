#!/usr/bin/env bash
# Push a branch to origin, then post the result and the pushed commits to Discord.
# Exits with git push's status so `wt config state logs` still shows push failures.
set -uo pipefail

branch="${1:?usage: discord-push.sh <branch>}"
webhook_ref="op://Automation/homelab Discord webhook/credential"

before="$(git rev-parse --verify --quiet "origin/${branch}" || true)"
output="$(git push origin "${branch}" 2>&1)"
rc=$?
printf '%s\n' "${output}"
after="$(git rev-parse "${branch}")"

if [[ ${rc} -eq 0 ]]; then
  title="✅ Pushed ${branch}"
  color=3066993
  if [[ -n ${before} && ${before} != "${after}" ]]; then
    body="$(git log --format='`%h` %s (%an)' "${before}..${after}" | head -n 15)"
  else
    body="Already up to date at \`$(git rev-parse --short "${after}")\`"
  fi
else
  title="❌ Push of ${branch} failed (exit ${rc})"
  color=15158332
  body="$(printf '```\n%s\n```' "$(tail -n 15 <<<"${output}")")"
fi

if webhook="$(op read "${webhook_ref}" 2>/dev/null)"; then
  jq -n --arg title "${title}" --arg body "${body:0:4000}" --argjson color "${color}" \
    --arg footer "homelab · $(hostname -s)" \
    '{username: "homelab git", embeds: [{title: $title, description: $body, color: $color, footer: {text: $footer}}]}' |
    curl -fsS -H 'Content-Type: application/json' --data @- "${webhook}" >/dev/null ||
    echo "discord-push: failed to post to Discord" >&2
else
  echo "discord-push: could not read ${webhook_ref}" >&2
fi

exit "${rc}"
