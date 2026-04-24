{
  pkgs,
  pkgs-unstable,
  ...
}:

let
  rust = pkgs.rust-bin.fromRustupToolchainFile ../rust-toolchain.toml;
  rustCToolchain = import ./rust-c-toolchain.nix { inherit pkgs; };
  rustAnalyzerEnv = rustCToolchain.env // {
    PATH = "${rust}/bin:$PATH";
    CARGO = "${rust}/bin/cargo";
    RUSTC = "${rust}/bin/rustc";
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
    profiles.default = {
      userSettings = {
        "update.mode" = "none";
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "git.openRepositoryInParentFolders" = "never";
        "explorer.confirmDragAndDrop" = false;
        "jjk.pollSnapshotWorkingCopy" = true;
        # disable if jjk installed - jj dislikes
        "git.enabled" = false;
        "editor.inlineSuggest.enabled" = true;
        rust-analyzer = {
          server = {
            path = "${rust}/bin/rust-analyzer";
            extraEnv = rustAnalyzerEnv;
          };
          cargo = {
            extraEnv = rustAnalyzerEnv;
          };
          check = {
            extraEnv = rustAnalyzerEnv;
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
