{ pkgs, ... }:

let
  # In a directory with a secrets.env, runs tofu under `op run` so the op://
  # references resolve only inside tofu's process. Most references point at
  # the operator vault, which the default read-only service account cannot
  # read, hence app auth.
  tofu = pkgs.writeShellScriptBin "tofu" ''
    if [ -f secrets.env ]; then
      export OP_APP_AUTH=1
      exec op run --no-masking --account my.1password.com \
        --env-file secrets.env -- ${pkgs.opentofu}/bin/tofu "$@"
    fi
    exec ${pkgs.opentofu}/bin/tofu "$@"
  '';
in
{
  packages = [
    (pkgs.python3.withPackages (ps: [ ps.ansible ps.mitogen ]))
    pkgs.ansible-lint
    pkgs.go
    pkgs.pre-commit
    tofu
  ];

  # Keep the worktree after `wt merge` so the agent's shell keeps a valid cwd.
  env.WORKTRUNK_MERGE__REMOVE = "false";

  # MITOGEN: fork+file-descriptor broker so each task skips a fresh Python
  # startup on the ARM nodes; the strategy plugin path is a store path, so it
  # has to be resolved at shell entry instead of hardcoded in ansible.cfg.
  env.ANSIBLE_STRATEGY = "mitogen_linear";

  enterShell = ''
    export ANSIBLE_STRATEGY_PLUGINS="$(python -c 'import os, ansible_mitogen; print(os.path.join(os.path.dirname(ansible_mitogen.__file__), "plugins/strategy"))')"
    pre-commit install >/dev/null
  '';
}
