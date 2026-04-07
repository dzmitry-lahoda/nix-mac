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

 programs.ssh = {
    enable = true;

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
        identitiesOnly = true;
        addKeysToAgent = "yes";
        # non mac native git cannot use apple hardware so easy,
        # 
        #extraOptions = {
        #  UseKeychain = "yes";
        #};
      };
    };
  };
  
  programs.home-manager.enable = true;
  programs.bash.enable = true;

  home.activation.setGhosttyDefault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v duti >/dev/null 2>&1; then
      duti -s com.mitchellh.ghostty public.unix-executable all || true
      duti -s com.mitchellh.ghostty public.shell-script all || true
    fi
  '';

programs.vscode = {
  profiles.default.extensions = with pkgs.vscode-extensions; [
    rust-lang.rust-analyzer
    jnoortheen.nix-ide
    ckolkman.vscode-postgres
    yzhang.markdown-all-in-one
  ];
};

# sudo nix run nix-darwin#darwin-rebuild -- switch --flake .#dzs-MacBook-Pro
  home.packages = with pkgs; [
    codex
    git
    git-lfs
    gh
    ghostty-bin
    zellij
    ripgrep
    bat
    bottom
    skim
    eza
    fd
    zoxide
    procs
    dust
    sd
    delta
    duti
    vscode
    openssh
  ];
}
