{
  pkgs,
  pkgs-unstable,
  pkgs-lmstudio,
  zed,
  lib,
  ...
}:

let
  username = "dz";
  homeDir = "/Users/${username}";
  host = "dzs-MacBook-Pro.local";
  email = "dzmitry@lahoda.pro";
  system = pkgs.stdenv.hostPlatform.system;
  rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
  rustExtraEnv = {
    PATH = "${rust}/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin";
  };
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
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    sessionVariables = {
      SSH_AUTH_SOCK = "${homeDir}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
      PATH = "$HOME/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH";
      PROTOC = "${pkgs.protobuf}/bin/protoc";
    };
    # initExtra = ''
    #   __prompt_path() {
    #     local path="''${PWD/#$HOME/~}"
    #     local IFS='/'
    #     local parts=()
    #     local out=""
    #     local i

    #     read -r -a parts <<< "$path"
    #     for i in "''${!parts[@]}"; do
    #       local part="''${parts[$i]}"
    #       if [ -z "$part" ]; then
    #         continue
    #       fi
    #       if [ "$i" -lt "$((''${#parts[@]} - 1))" ] && [ "''${#part}" -gt 2 ]; then
    #         out="$out/''${part:0:2}."
    #       else
    #         out="$out/$part"
    #       fi
    #     done

    #     if [ -z "$out" ]; then
    #       printf '/'
    #     else
    #       printf '%s' "$out"
    #     fi
    #   }

    #   __prompt_jj_mark() {
    #     jj root >/dev/null 2>&1 && printf ' [jj]'
    #   }

    #   PS1='$(__prompt_path)$(__prompt_jj_mark) \$ '

    #   bind '"\e[A": history-search-backward'
    #   bind '"\e[B": history-search-forward'
    # '';
  };
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    package = pkgs-unstable.atuin;
  };
  programs.starship = {
    enable = true; # not sure if i need it a all - it also lack shortened path
    enableBashIntegration = true;
    package = pkgs.starship;
    settings = {
      # directory = {
      #     truncation_length = 2;
      #     truncation_symbol = "…/";
      # };
      add_newline = false;
      # assumes i do not need all infor on each line
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$singularity"
        "$kubernetes"
        "$directory"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$custom"
        "$sudo"
        "$jobs"
        "$status"
        "$os"
        "$container"
        "$netns"
        "$shell"
        "$character"
      ];
      custom.jj_bookmark = {
        command = "${pkgs-unstable.jujutsu}/bin/jj log -r 'latest(ancestors(@) & bookmarks())' --no-graph -T 'bookmarks.join(\" \")'";
        when = "test -n \"$(${pkgs-unstable.jujutsu}/bin/jj log -r 'latest(ancestors(@) & bookmarks())' --no-graph -T 'bookmarks.join(\" \")' 2>/dev/null)\"";
        format = "[$symbol$output]($style) ";
        symbol = "jj ";
        style = "purple";
      };
      package.disabled = false;
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
        behavior = "drop"; # must be such to avoid loop sign by mac hardware key
        backends.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
      };
      git.sign-on-push = true;
    };
  };
  programs.anki = {
    enable = true;
    package = pkgs-unstable.anki;
  };
  programs.zed-editor = {
    enable = true;
    package = zed.packages.${system}.default;
  };

  services.syncthing = {
    enable = true;
    settings.options.urAccepted = 1;
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
        "jjk.pollSnapshotWorkingCopy" = true;
        # disable if jjk installed - jj dislikes
        "git.enabled" = false;
        "editor.inlineSuggest.enabled" = true;
        rust-analyzer = {
          server = {
            path = "${rust}/bin/rust-analyzer";
            extraEnv = rustExtraEnv;
          };
          cargo = {
            extraEnv = rustExtraEnv;
          };
          check = {
            extraEnv = rustExtraEnv;
          };
        };
      };
      extensions = with pkgs-unstable.vscode-extensions; [
        rust-lang.rust-analyzer
        jnoortheen.nix-ide
        yzhang.markdown-all-in-one
        github.vscode-github-actions
        continue.continue
        # fucks all extension
        #tamasfe.even-better-toml

        jjk.jjk

        # not yet available
        # ckolkman.vscode-postgres
        # openai.chatgpt
      ];
    };
  };

  home.packages =
    (with pkgs; [
      # clang
      llvmPackages.clang-unwrapped # rust expects not nix - but full clang with cross compile and debug
      git
      git-lfs
      act
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
      rust
    ])
    ++ (with pkgs-unstable; [
      codex
      typst
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
    ])
    ++ (with pkgs-lmstudio; [
      lmstudio
    ]);
}
