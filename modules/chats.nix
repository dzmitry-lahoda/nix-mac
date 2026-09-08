{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    signal-desktop
    telegram-desktop
  ];
}
