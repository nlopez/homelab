#!/usr/bin/env bash
# Helper to find unique terraform stack directories from changed files.
# Usage: terraform-stack-dirs.sh <file1> [<file2> ...]
# Outputs one absolute directory per line, sorted and deduplicated.
set -euo pipefail

dirs=""
for file in "$@"; do
  dir=$(cd "$(dirname "$file")" && pwd)

  # Find the stack root: the directory with .tf files closest to the changed file
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir"/.tf ]] || ls "$dir"/*.tf >/dev/null 2>&1; then
      dirs+="$dir"$'\n'
      break
    fi
    dir=$(dirname "$dir")
  done
done

if [[ -z "$dirs" ]]; then
  exit 0
fi

echo -n "$dirs" | sort -u
