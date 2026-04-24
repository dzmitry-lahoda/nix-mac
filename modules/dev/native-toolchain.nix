{ pkgs }:

let
  # Use wrapped toolchain binaries on Darwin so the SDK/sysroot and linker
  # search paths are injected automatically.
  clang = pkgs.llvmPackages.clang;
  clangUnwrapped = pkgs.llvmPackages.clang-unwrapped;
  bintools = pkgs.llvmPackages.bintools;
  libiconv = pkgs.libiconv;
  appleSdk = pkgs.apple-sdk_26;
in
{
  inherit clang clangUnwrapped bintools libiconv appleSdk;

  packages = [
    clang
    pkgs.darwin.libiconv
    pkgs.libllvm
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
  unwrappedEnv = {
    CC = "${clangUnwrapped}/bin/clang";
    # AR = "${clangUnwrapped}/bin/llvm-ar";
    CXX = "${clangUnwrapped}/bin/clang++";
    # CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER = "${clangUnwrapped}/bin/clang";
    # PATH = "${clangUnwrapped}/bin:$PATH";
  };
}
