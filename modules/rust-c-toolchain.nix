{ pkgs }:

let
  # Use wrapped toolchain binaries on Darwin so the SDK/sysroot and linker
  # search paths are injected automatically.
  clang = pkgs.llvmPackages.clang;
  bintools = pkgs.llvmPackages.bintools;
  libiconv = pkgs.libiconv;
  appleSdk = pkgs.apple-sdk_14;
in
{
  inherit clang bintools libiconv appleSdk;

  packages = [
    clang
    libiconv
    pkgs.gnumake
    pkgs.cmake
    pkgs.pkg-config
  ];

  env = {
    CC = "${clang}/bin/clang";
    # The wrapped clang toolchain already exposes binutils; avoid adding
    # standalone bintools to home.packages because both provide `strip`.
    AR = "${clang}/bin/ar";
    CXX="${clang}/bin/clang";
    CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="${clang}/bin/clang";
    # `clang` still needs an explicit library search path for Nix-provided
    # Darwin libs like libiconv when Cargo links binaries directly.
    LIBRARY_PATH = "${libiconv}/lib";
    # Rust probes these directly on Darwin before invoking the wrapper.
    DEVELOPER_DIR = "${appleSdk}";
    SDKROOT = "${appleSdk}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk";
  };
}
