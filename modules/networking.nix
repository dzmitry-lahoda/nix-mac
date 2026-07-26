{ pkgs-unstable, ... }:

{
  home.packages = [
    (pkgs-unstable.ivpn.overrideAttrs {
      buildInputs = [ ];
    })
  ];
}
