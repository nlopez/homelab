#!/usr/bin/env bash
# Lists the resources an OpenTofu plan deletes or replaces, one per line as
# "<address> (<actions>)", from `tofu show -json` on stdin. Only addresses and
# actions leave the JSON plan, which can hold secrets. Prints nothing when the
# plan destroys nothing. Run by .github/actions/tofu-plan.
set -euo pipefail

jq -r '.resource_changes[]?
  | select(.change.actions | index("delete"))
  | "\(.address) (\(.change.actions | join(" then ")))"'
