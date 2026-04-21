{ pkgs }:

let
  clang = pkgs.llvmPackages.clang-unwrapped;
  bintools = pkgs.bintools-unwrapped;
in
{
  inherit clang bintools;

  packages = [
    bintools
    clang
  ];

  env = {
    CC = "${clang}/bin/clang";
    AR = "${bintools}/bin/ar";
  };
}
