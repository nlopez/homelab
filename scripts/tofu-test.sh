#!/usr/bin/env bash
# Run OpenTofu tests in directories where test files changed.
# Tests run with no credentials, no network to cloud APIs, and no backend.
# Uses -chdir to avoid triggering the flake.nix tofu wrapper's 1Password integration.
set -euo pipefail

# Get list of changed files from pre-commit
files=("$@")

# Find unique directories containing changed .tftest.hcl or .tf files
dirs=()
for file in "${files[@]}"; do
  if [[ "$file" == *.tftest.hcl ]] || [[ "$file" == *.tf ]]; then
    dir=$(dirname "$file")
    # Only run test if the directory has at least one .tftest.hcl file
    if ls "$dir"/*.tftest.hcl 1>/dev/null 2>&1; then
      dirs+=("$dir")
    fi
  fi
done

if [ ${#dirs[@]} -eq 0 ]; then
  exit 0
fi

# Remove duplicates using sort -u with while-read (macOS bash 3.2 compat; no mapfile)
declare -A unique_dirs
while IFS= read -r dir; do
  unique_dirs["$dir"]=1
done < <(printf '%s\n' "${dirs[@]}" | sort -u)
dirs=("${!unique_dirs[@]}")

# Use a shared plugin cache outside the repo to speed up test runs
export TF_PLUGIN_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/terraform-plugins"
mkdir -p "$TF_PLUGIN_CACHE_DIR"

# Run tests in each directory
for dir in "${dirs[@]}"; do
  echo "Testing $dir..."

  # Initialize: use -lockfile=readonly for root modules but allow writes for child modules
  # (child modules in aws/modules/ should not have lock files, so init must create them)
  init_args=(-backend=false -input=false)
  if [[ ! "$dir" =~ ^aws/modules/ ]]; then
    init_args+=(-lockfile=readonly)
  fi

  if ! tofu -chdir="$dir" init "${init_args[@]}" 2>&1; then
    echo "ERROR: tofu init failed in $dir" >&2
    exit 1
  fi

  # Run tests
  if ! tofu -chdir="$dir" test; then
    exit 1
  fi
done
