{ pkgs, lib, ... }:

let
  username = "dz";
  homeDir = "/Users/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";


home.file.".config/nixpkgs/config.nix".text = ''
    allowUnfree = true;
  '';


  programs.home-manager.enable = true;
  programs.bash.enable = true;


programs.vscode = {
  profiles.default.extensions = with pkgs.vscode-extensions; [
    yzhang.markdown-all-in-one
  ];
};

  home.packages = with pkgs; [
    codex
    git
    vscode
  ];
}
