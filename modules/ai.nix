{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-lmstudio,
  codex-cli-nix,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  tomlFormat = pkgs.formats.toml { };
  yamlFormat = pkgs.formats.yaml { };
  codexConfig = {
    personality = "pragmatic";
    model = "gpt-5.4";

    projects = {
      "/Users/dz/overlay/github.com/dzmitry-lahoda/nix-mac".trust_level = "trusted";
      "/Users/dz/overlay/github.com/n1xyz/proton".trust_level = "trusted";
      "/Users/dz/Downloads".trust_level = "trusted";
      "/Users/dz/overlay/github.com/keanemind/jjk".trust_level = "trusted";
      "/Users/dz/overlay/github.com/dzmitry-lahoda/rowview".trust_level = "trusted";
    };

    plugins = {
      "google-calendar@openai-curated".enabled = true;
      "gmail@openai-curated".enabled = true;
      "slack@openai-curated".enabled = true;
      "github@openai-curated".enabled = true;
    };

    apps.connector_76869538009648d5b282a4bb21c3d157.tools.github_create_pull_request.approval_mode =
      "approve";
  };
  shellGptConfig = {
    OPENAI_API_KEY = "lm-studio";
    API_BASE_URL = "http://127.0.0.1:1234/v1";
    DEFAULT_MODEL = "openai/qwen/qwen3.6-27b";
    USE_LITELLM = true;
    OPENAI_USE_FUNCTIONS = false;
  };
  continueConfig = {
    name = "Local Continue";
    version = "1.0.0";
    schema = "v1";
    models = [
      {
        name = "lmstudio qwen/qwen3.6-27b";
        provider = "lmstudio";
        model = "qwen/qwen3.6-27b";
        apiBase = "http://localhost:1234/v1";
        roles = [
          "chat"
          "edit"
          "apply"
          "autocomplete"
        ];
        autocompleteOptions = {
          disable = false;
          debounceDelay = 250;
          maxPromptTokens = 1024;
          modelTimeout = 150;
          maxSuffixPercentage = 0.2;
          prefixPercentage = 0.3;
          onlyMyCode = false;
        };
      }
    ];
  };
in
{
  home.file.".codex/config.toml".source = tomlFormat.generate "codex-config.toml" codexConfig;

  home.file.".config/shell_gpt/.sgptrc".text = lib.generators.toKeyValue { } shellGptConfig;

  home.file.".continue/config.yaml".source = yamlFormat.generate "continue-config.yaml" continueConfig;

  home.file.".gemini/settings.json".text =
    builtins.toJSON {
      ide = {
        hasSeenNudge = true;
        enabled = true;
      };
      model = {
        name = "gemini-3.1-pro-preview";
      };
      security = {
        auth = {
          selectedType = "oauth-personal";
        }; 
      };
    };

  home.packages = [
    codex-cli-nix.packages.${system}.codex
    pkgs-unstable.gemini-cli
    pkgs-unstable.shell-gpt
  ]
  ++ (with pkgs-lmstudio; [
    lmstudio
  ]);
}
