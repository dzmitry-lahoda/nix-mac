{
  pkgs,
  pkgs-unstable,
  pkgs-lmstudio,
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
  home.file.".continue/config.yaml".text = ''
    name: Local Continue
    version: 1.0.0
    schema: v1

    models:
      - name: LM Studio Qwen3 Coder 30B
        provider: lmstudio
        model: qwen/qwen3-coder-30b
        apiBase: http://localhost:1234/v1
        roles:
          - chat
          - edit
          - apply
          - autocomplete
        autocompleteOptions:
          disable: false
          debounceDelay: 250
          maxPromptTokens: 1024
          modelTimeout: 150
          maxSuffixPercentage: 0.2
          prefixPercentage: 0.3
          onlyMyCode: true
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
  programs.gh = {
    enable = true;
    package = pkgs.gh;
  };
  programs.gitui = {
    enable = true;
    package = pkgs.gitui;
  };
  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      user = {
        name = username;
        email = email;
      };
      signing = {
        backend = "ssh";
        key = "${homeDir}/.ssh/id_ed25519_github.pub";
        behavior = "own";
        backends.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
      };
      git.sign-on-push = true;
    };
  };
  programs.anki = {
    enable = true;
    package = pkgs-unstable.anki;
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
        "explorer.confirmDragAndDrop" = false;
        "git.enabled" = false;
        "editor.inlineSuggest.enabled" = true;
      };
      extensions = with pkgs-unstable.vscode-extensions; [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        yzhang.markdown-all-in-one
        github.vscode-github-actions
        jjk.jjk
        continue.continue
        
        # not yet available
        # ckolkman.vscode-postgres
        # openai.chatgpt
      ];
    };
  };

  home.packages =
    (with pkgs; [
      clang
      git
      git-lfs
      # must be be deeply integrated - seems needs cask
      # brave
      ghostty-bin
      # note - only for linux...
      # ledger-live-desktop
      android-tools
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
      lazyjj
      jjui
      process-compose
      zellij
      pijul
      secretive
      whatsapp-for-mac
      trezord
      signal-desktop
      telegram-desktop
      swift
      lean4
      zig
    ]) ++ (with pkgs-lmstudio; [
      lmstudio
    ]);
}
