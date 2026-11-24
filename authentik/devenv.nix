{ pkgs, ... }:

let
  # Runs tofu with the op:// references in secrets.env resolved, so the
  # secrets exist only in tofu's process. The API token is in the operator
  # vault, outside the Automation-vault service account, hence app auth.
  tofu = pkgs.writeShellScriptBin "tofu" ''
    export OP_APP_AUTH=1
    exec op run --no-masking --account my.1password.com \
      --env-file ${./secrets.env} -- ${pkgs.opentofu}/bin/tofu "$@"
  '';
in
{
  packages = [
    tofu
  ];
}
