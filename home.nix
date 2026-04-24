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
  rustCToolchain = import ./modules/dev/native-toolchain.nix { inherit pkgs; };
in
{
  imports = [
    ./modules/ai.nix
    ./modules/chats.nix
    ./modules/cli.nix
    ./modules/dev/tools.nix
    ./modules/media.nix
    ./modules/vm.nix
    ./modules/dev/vscode.nix
    ./modules/dev/zed-editor.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";
  home.file.".config/nixpkgs/config.nix".text = ''
    allowUnfree = true;
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
    } // rustCToolchain.env;
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

  home.packages =
    (with pkgs; [
      # must be be deeply integrated - seems needs cask
      # brave
      ghostty-bin
      # note - only for linux...
      # ledger-live-desktop
      duti
      openssh
    ])
    ++ (with pkgs-unstable; [
      secretive
      trezord
    ]);
}
