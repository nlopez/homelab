#!/usr/bin/env bash
# Reads `tofu show -no-color` output on stdin and prints it as a Markdown diff
# block, so GitHub colors additions, destroys, and in-place changes. Each
# action marker moves to column 0, where diff highlighting looks for it;
# updates (~) and replaces (-/+, +/-) become `!`. Keeps the last 60000 bytes,
# under the 1 MiB step summary and 65536-character comment limits.
set -euo pipefail

echo '```diff'
tail -c 60000 | sed -E \
  -e 's/^( *)(-\/\+|\+\/-) /!\1   /' \
  -e 's/^( *)([-+~]) /\2\1 /' \
  -e 's/^~/!/'
echo '```'
