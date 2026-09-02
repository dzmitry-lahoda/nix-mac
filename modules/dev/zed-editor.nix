{
  pkgs,
  zed,
  localAi ? {
    defaultLocal = "fortytwo-network-strand-rust-coder-14b-v1";
    ollamaHost = "127.0.0.1:11434";
    ollamaApiBase = "http://127.0.0.1:11434";
    ollamaModel = "fortytwo-network-strand-rust-coder-14b-v1:latest";
  },
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # NOTE: fails on nightly 
  # programs.zed-editor = {
  #   enable = true;
  #   package = zed.packages.${system}.default;
  #   extensions = [
  #     "zig"
  #     "lean4"
  #     "swift"
  #     "rust"
  #   ];
  #   userSettings = {
  #     auto_update = false;
  #     edit_predictions = {
  #       provider = "open_ai_compatible_api";
  #       open_ai_compatible_api = {
  #         api_url = "${localAi.ollamaApiBase}/v1/completions";
  #         model = localAi.defaultLocal;
  #         prompt_format = "qwen";
  #         max_output_tokens = 64;
  #       };
  #     };
  #   };
  # };
}
