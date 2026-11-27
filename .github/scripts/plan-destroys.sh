#!/usr/bin/env bash
# Lists the resources an OpenTofu plan deletes or replaces, one per line as
# "<address> (<actions>)", from `tofu show -json` on stdin. Only addresses and
# actions leave the JSON plan, which can hold secrets. Prints nothing when the
# plan destroys nothing. terraform_data is skipped: it holds no real
# infrastructure, and replacing it is how a trigger re-runs its provisioner.
# Run by .github/actions/tofu-plan.
set -euo pipefail

jq -r '.resource_changes[]?
  | select(.type != "terraform_data")
  | select(.change.actions | index("delete"))
  | "\(.address) (\(.change.actions | join(" then ")))"'
