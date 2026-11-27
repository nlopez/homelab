#!/usr/bin/env bash
# Validates OpenTofu code per stack directory, using a shared plugin cache.
# Pre-commit passes filenames as arguments; we extract unique stack directories
# and validate each one.
#
# Uses -chdir to avoid triggering the tofu wrapper's op run when secrets.env exists
# in a directory. The wrapper only checks the current working directory, so using
# -chdir skips it and avoids 1Password prompts for validation (which needs no secrets).
set -euo pipefail

# Cache directory for terraform plugins - absolute path outside the repo
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/terraform-plugins}"
mkdir -p "$TF_PLUGIN_CACHE_DIR"

# Get unique stack directories from the changed files
dirs=$(bash "$(dirname "$0")/terraform-stack-dirs.sh" "$@")

if [[ -z "$dirs" ]]; then
  exit 0
fi

exit_code=0
while IFS= read -r dir; do
  echo "Validating $dir..." >&2

  # Detect if this is a module (no backend block) or a stack (has backend)
  if grep -q "^\s*backend\s" "$dir"/*.tf 2>/dev/null; then
    # Stack: use -lockfile=readonly to avoid changing lock files
    if ! tofu -chdir="$dir" init -backend=false -input=false -lockfile=readonly >/dev/null; then
      exit_code=1
      continue
    fi
  else
    # Module: don't enforce readonly lockfile (may not exist yet).
    # Print init errors so we can debug any real problems.
    if ! tofu -chdir="$dir" init -backend=false -input=false >/dev/null; then
      exit_code=1
      continue
    fi
  fi

  # Validate the configuration
  if ! tofu -chdir="$dir" validate; then
    exit_code=1
  fi
done <<< "$dirs"

exit "$exit_code"
