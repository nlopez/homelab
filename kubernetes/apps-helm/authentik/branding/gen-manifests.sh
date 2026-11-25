#!/usr/bin/env bash
# Renders the Desert Bluffs brand assets into the ConfigMap that the
# authentik pods mount under web/dist. Run after editing any *.svg here:
#   ./gen-manifests.sh
# ConfigMap keys cannot contain '/', so the mount layout is rebuilt from
# the dotted keys in authentik/brand.tf.
set -euo pipefail
cd "$(dirname "$0")"
env_nix="$(mktemp -d)/env.nix"
printf '%s\n' 'let pkgs = import <nixpkgs> {};' \
  'in pkgs.python3.withPackages (ps: [ps.cairosvg])' > "$env_nix"
exec nix shell --file "$env_nix" --command python3 gen_manifests.py
