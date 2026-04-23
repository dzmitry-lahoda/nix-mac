{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tart
    utm
    whisky
  ];
}
