{
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    pkgs.vlc-bin
    pkgs-unstable.webtorrent_desktop
  ];
}
