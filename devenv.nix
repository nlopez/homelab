{ pkgs, ... }:

{
  packages = [
    pkgs.go
    pkgs.pre-commit
    pkgs.uv
  ];

  # Keep the worktree after `wt merge` so the agent's shell keeps a valid cwd.
  env.WORKTRUNK_MERGE__REMOVE = "false";

  enterShell = ''
    pre-commit install >/dev/null
  '';
}
