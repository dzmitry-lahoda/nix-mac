{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    signal-desktop
    telegram-desktop
    whatsapp-for-mac
  ];
}
