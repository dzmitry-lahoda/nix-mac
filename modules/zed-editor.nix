{
  pkgs,
  zed,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.zed-editor = {
    enable = true;
    package = zed.packages.${system}.default;
    extensions = [
      "zig"
      "lean4"
      "swift"
      "rust"
    ];
    userSettings = {
      auto_update = false;
      edit_predictions = {
        provider = "open_ai_compatible_api";
        open_ai_compatible_api = {
          api_url = "http://127.0.0.1:1234/v1/completions";
          model = "qwen/qwen3.6-27b";
          prompt_format = "qwen";
          max_output_tokens = 64;
        };
      };
    };
  };
}
