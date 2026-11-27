#!/usr/bin/env bash
# Runs tflint on changed OpenTofu stacks with shared plugin cache.
# Uses absolute path to root .tflint.hcl config and runs from repo root with --chdir
# to ensure the terraform recommended preset and AWS ruleset are applied.
set -euo pipefail

# Find the repo root
repo_root=$(git rev-parse --show-toplevel)

# Get unique stack directories from the changed files
dirs=$(bash "$repo_root/scripts/terraform-stack-dirs.sh" "$@")

if [[ -z "$dirs" ]]; then
  exit 0
fi

exit_code=0
while IFS= read -r dir; do
  echo "Linting $dir..." >&2

  # Initialize tflint plugins once per directory, with explicit config
  if ! tflint --init --config="$repo_root/.tflint.hcl" --chdir="$dir"; then
    exit_code=1
  fi

  # Run tflint with the root config. For modules, disable rules not applicable to them.
  tflint_args=("--config=$repo_root/.tflint.hcl" "--chdir=$dir")

  # Detect if this is a module (no backend block) and disable module-specific rules
  if ! grep -q "^\s*backend\s" "$dir"/*.tf 2>/dev/null; then
    # Module: disable rules that apply only to stacks (which define the constraints)
    tflint_args+=("--disable-rule=terraform_required_version")
    tflint_args+=("--disable-rule=terraform_required_providers")
  fi

  if ! tflint "${tflint_args[@]}"; then
    exit_code=1
  fi
done <<< "$dirs"

exit "$exit_code"
