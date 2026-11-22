{ pkgs, ... }:

{
  packages = [
    pkgs.opentofu
  ];

  enterShell = ''
    echo "$(tofu version | head -1)"
  '';
}
