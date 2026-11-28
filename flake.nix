{
  description = "Dev shell for the homelab repo: the tools the stacks and the pre-commit hooks need";

  # Renovate's nix manager keeps flake.lock current.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forEachSystem (
        pkgs:
        let
          # In a directory with a secrets.env, runs tofu under `op run` so the
          # op:// references resolve only inside tofu's process. Most
          # references point at the operator vault, which the default
          # read-only service account cannot read, hence app auth.
          tofu = pkgs.writeShellScriptBin "tofu" ''
            if [ -f secrets.env ]; then
              export OP_APP_AUTH=1
              exec op run --no-masking --account my.1password.com \
                --env-file secrets.env -- ${pkgs.opentofu}/bin/tofu "$@"
            fi
            exec ${pkgs.opentofu}/bin/tofu "$@"
          '';

          # credential_process for the profiles in aws/config. Prints
          # short-lived credentials for an SSO profile, opening the browser to
          # sign in first when the SSO session has expired. stdout carries only
          # the credentials JSON.
          aws-sso-creds = pkgs.writeShellScriptBin "aws-sso-creds" ''
            set -euo pipefail
            if ! aws configure export-credentials --profile "$1" --format process 2>/dev/null; then
              aws sso login --profile "$1" >&2
              aws configure export-credentials --profile "$1" --format process
            fi
          '';

          python = pkgs.python3.withPackages (ps: [
            ps.ansible
            ps.mitogen
          ]);
        in
        {
          default = pkgs.mkShell {
            packages = [
              python
              pkgs.ansible-lint
              pkgs.betterleaks
              pkgs.go
              pkgs.pre-commit
              pkgs.tflint
              tofu
              aws-sso-creds
            ];

            # MITOGEN: fork+file-descriptor broker so each task skips a fresh
            # Python startup on the ARM nodes.
            ANSIBLE_STRATEGY = "mitogen_linear";

            shellHook = ''
              root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
              export AWS_CONFIG_FILE="$root/aws/config"
              # The strategy plugin path is a store path, so it is resolved here
              # instead of hardcoded in ansible.cfg.
              ANSIBLE_STRATEGY_PLUGINS="$(python -c 'import os, ansible_mitogen; print(os.path.join(os.path.dirname(ansible_mitogen.__file__), "plugins/strategy"))')"
              export ANSIBLE_STRATEGY_PLUGINS
              (cd "$root" && pre-commit install >/dev/null) || true
            '';
          };
        }
      );
    };
}
