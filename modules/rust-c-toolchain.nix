{ pkgs }:

let
  clang = pkgs.llvmPackages.clang-unwrapped;
  bintools = pkgs.llvmPackages.bintools-unwrapped;
  libiconv = pkgs.libiconv;
in
{
  inherit clang bintools libiconv;

  packages = [
    bintools
    clang
    libiconv
    pkgs.gnumake
    pkgs.cmake
    pkgs.pkg-config
  ];

  env = {
    CC = "${clang}/bin/clang";
    AR = "${bintools}/bin/ar";
  };
}
