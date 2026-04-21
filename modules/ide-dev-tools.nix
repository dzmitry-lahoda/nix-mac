{
  pkgs,
  pkgs-unstable,
  ...
}:

let
  rust = pkgs.rust-bin.fromRustupToolchainFile ../rust-toolchain.toml;
  rustCToolchain = import ./rust-c-toolchain.nix { inherit pkgs; };
in
{
  home.packages =
    rustCToolchain.packages
    ++ (with pkgs; [
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
