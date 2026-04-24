{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    tart
    utm
    # whisky - depercated and seems cannot do steam well
    ];
}
