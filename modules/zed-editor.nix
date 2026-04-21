{
  pkgs,
  zed,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.zed-editor = {
    enable = true;
    package = zed.packages.${system}.default;
  };
}
