{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

let
  username = "dz";
  homeDir = "/Users/${username}";
  host = "dzs-MacBook-Pro.local";
  email = "dzmitry@lahoda.pro";
in
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";
  home.file.".config/nixpkgs/config.nix".text = ''
    allowUnfree = true;
  '';
  home.file.".config/jj/config.toml".text = ''
    [user]
    name = "${username}"
    email = "${email}"
  '';

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  programs.home-manager.enable = true;
  programs.bash = {
    enable = true;
    sessionVariables = {
      SSH_AUTH_SOCK = "${homeDir}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
      PATH = "$HOME/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH";
    };
  };
  programs.git = {
    enable = true;
    settings = {
      core.editor = "hx";
      user.name = username;
      user.email = email;
      user.signingkey = "${homeDir}/.ssh/id_ed25519_github.pub";
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgSign = true;
    };
  };

  services.syncthing = {
    enable = true;
  };

  home.activation.setGhosttyDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v duti >/dev/null 2>&1; then
      duti -s com.mitchellh.ghostty public.unix-executable all || true
      duti -s com.mitchellh.ghostty public.shell-script all || true
    fi
  '';

  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
    profiles.default = {
      userSettings = {
        "git.openRepositoryInParentFolders" = "never";
      };
      extensions = with pkgs-unstable.vscode-extensions; [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        yzhang.markdown-all-in-one
        github.vscode-github-actions
        github.copilot
        # not yet available
        # ckolkman.vscode-postgres
        # openai.chatgpt

      ];
    };
  };

  home.packages =
    (with pkgs; [
      git
      git-lfs
      gh
      # must be be deeply integrated - seems needs cask
      # brave
      ghostty-bin
      gitui
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
      openssh
      (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
    ])
    ++ (with pkgs-unstable; [
      codex
      gemini-cli
      helix
      jujutsu
      process-compose
      zellij
      secretive
    ]);
}
