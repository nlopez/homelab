#!/bin/bash
# Runs tflint on changed OpenTofu stacks with shared plugin cache.
set -euo pipefail

# Cache directory for tflint plugins - absolute path outside the repo
export TFLINT_PLUGIN_DIR="${TFLINT_PLUGIN_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/tflint-plugins}"
mkdir -p "$TFLINT_PLUGIN_DIR"

# Collect unique stack directories containing the changed files
declare -A dirs
for file in "$@"; do
  dir=$(cd "$(dirname "$file")" && pwd)

  # Find the stack root: the directory with .tf files closest to the changed file
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir"/.tf ]] || ls "$dir"/*.tf &>/dev/null 2>&1; then
      dirs["$dir"]=1
      break
    fi
    dir=$(dirname "$dir")
  done
done

if [[ ${#dirs[@]} -eq 0 ]]; then
  exit 0
fi

exit_code=0
for dir in "${!dirs[@]}"; do
  echo "Linting $dir..." >&2

  if ! (
    cd "$dir"
    tflint --init >/dev/null 2>&1 || true
    tflint
  ); then
    exit_code=1
  fi
done

exit "$exit_code"
