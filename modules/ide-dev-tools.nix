{
  pkgs,
  pkgs-unstable,
  zed,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  rust = pkgs.rust-bin.fromRustupToolchainFile ../rust-toolchain.toml;
in
{
  programs.zed-editor = {
    enable = true;
    package = zed.packages.${system}.default;
  };

  home.packages =
    (with pkgs; [
      # clang
      llvmPackages.clang-unwrapped # rust expects not nix - but full clang with cross compile and debug
      android-tools
      git
      git-lfs
      act
      openssh
      rust
    ])
    ++ (with pkgs-unstable; [
      helix
      jjui
      lazyjj
      lean4
      pijul
      process-compose
      swift
      typst
      zellij
      zig
    ]);
}
