{ pkgs, ... }:

{
  packages = [
    pkgs.ansible
    pkgs.ansible-lint
    pkgs.go
    pkgs.pre-commit
  ];

  # Keep the worktree after `wt merge` so the agent's shell keeps a valid cwd.
  env.WORKTRUNK_MERGE__REMOVE = "false";

  enterShell = ''
    pre-commit install >/dev/null
  '';
}
