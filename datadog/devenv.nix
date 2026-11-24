{ pkgs, ... }:

let
  # Runs tofu with the homelab-datadog 1Password Environment loaded, so the
  # secrets exist only in tofu's process. Environments are outside the
  # Automation-vault service account, hence app auth.
  tofu = pkgs.writeShellScriptBin "tofu" ''
    export OP_APP_AUTH=1
    exec op run --no-masking --account my.1password.com \
      --environment 4sirub7i26qlewsosiw4as3rbe -- ${pkgs.opentofu}/bin/tofu "$@"
  '';
in
{
  packages = [
    tofu
  ];
}
