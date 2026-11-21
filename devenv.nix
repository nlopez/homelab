{ pkgs, ... }:

{
  packages = [
    pkgs.dnscontrol
    pkgs.go
    pkgs.pre-commit
    pkgs.uv
  ];

  enterShell = ''
    pre-commit install >/dev/null
  '';
}
