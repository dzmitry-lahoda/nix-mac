{ pkgs }:

let
  clang = pkgs.llvmPackages.clang-unwrapped;
  bintools = pkgs.bintools-unwrapped;
  libiconv = pkgs.libiconv;
in
{
  inherit clang bintools libiconv;

  packages = [
    bintools
    clang
    libiconv
  ];

  env = {
    CC = "${clang}/bin/clang";
    AR = "${bintools}/bin/ar";
  };
}
