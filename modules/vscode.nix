{
  pkgs,
  pkgs-unstable,
  ...
}:

let
  username = "dz";
  rust = pkgs.rust-bin.fromRustupToolchainFile ../rust-toolchain.toml;
  rustExtraEnv = {
    PATH = "${rust}/bin:/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin";
  };
in
{
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
}
