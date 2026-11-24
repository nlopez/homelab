{ pkgs, ... }:

let
  # Runs tofu with the homelab-tailnet 1Password Environment loaded, so the
  # secrets exist only in tofu's process. Environments are outside the
  # Automation-vault service account, hence app auth.
  tofu = pkgs.writeShellScriptBin "tofu" ''
    export OP_APP_AUTH=1
    exec op run --no-masking --account my.1password.com \
      --environment 5535p5q4j6q6x26fwoqdtx665y -- ${pkgs.opentofu}/bin/tofu "$@"
  '';
in
{
  packages = [
    tofu
  ];

  enterShell = ''
    echo "$(${pkgs.opentofu}/bin/tofu version | head -1)"
  '';
}
