#!/bin/bash
# Gives a Claude Code cloud session the tools the pre-commit hooks need.
#
# The dev shell (devenv) is the normal way to get them, but cloud sessions
# can't build it: devenv fetches its pinned nixpkgs from GitHub, which the
# session's proxy refuses. This installs the same tools from the Nix binary
# cache and PyPI instead, then installs the git hooks and their environments,
# so commits there run the same checks as everywhere else (AGENTS.md).
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}"

# The hooks call tofu, ansible-lint, ansible-galaxy, and go directly
# (language: system and golang in .pre-commit-config.yaml).
if command -v nix >/dev/null; then
  missing=()
  command -v tofu >/dev/null || missing+=(nixpkgs#opentofu)
  command -v ansible-lint >/dev/null || missing+=(nixpkgs#ansible-lint)
  command -v ansible-galaxy >/dev/null || missing+=(nixpkgs#ansible)
  command -v go >/dev/null || missing+=(nixpkgs#go)
  if [ "${#missing[@]}" -gt 0 ]; then
    nix profile install "${missing[@]}"
  fi
else
  echo "session-start: nix is not installed; the tofu, ansible-lint, and kubeconform hooks will fail" >&2
fi

# nixpkgs' pre-commit can't build its virtualenvs here, so use PyPI's.
if ! command -v pre-commit >/dev/null; then
  python3 -m pip install --quiet pre-commit
fi

pre-commit install >/dev/null

# Build the hook environments up front, but only when the config or this
# script changed since the last successful build.
cache="${PRE_COMMIT_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/pre-commit}"
mkdir -p "${cache}"
hashes="${cache}/.session-start.sha256"
if ! sha256sum --check --status "${hashes}" 2>/dev/null; then
  rm -f "${hashes}"
  pre-commit install-hooks
  sha256sum .claude/hooks/session-start.sh .pre-commit-config.yaml > "${hashes}"
fi
