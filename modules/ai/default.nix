{
  lib,
  pkgs,
  pkgs-unstable,
  codex-cli-nix,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  tomlFormat = pkgs.formats.toml { };
  yamlFormat = pkgs.formats.yaml { };
  ollamaHost = "127.0.0.1:11434";
  ollamaApiBase = "http://${ollamaHost}";
  ollamaModel = "mlx-community-gemma-4-26b-a4b-it-4bit";
  ollamaService = pkgs.callPackage ./ollamaService.nix {
    ollama = pkgs-unstable.ollama;
    gemmaModel = pkgs.callPackage ./models/mlx-community-gemma-4-26b-a4b-it-4bit-mlx/weights.nix { };
    modelfile = pkgs.callPackage ./models/mlx-community-gemma-4-26b-a4b-it-4bit-mlx/modelfile.nix {
      gemmaModel = pkgs.callPackage ./models/mlx-community-gemma-4-26b-a4b-it-4bit-mlx/weights.nix { };
    };
  };
  codexConfig = {
    personality = "pragmatic";
    model = "gpt-5.5";

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
    OPENAI_API_KEY = "ollama";
    API_BASE_URL = "${ollamaApiBase}/v1";
    DEFAULT_MODEL = ollamaModel;
    USE_LITELLM = false;
    OPENAI_USE_FUNCTIONS = false;
  };
  continueConfig = {
    name = "Local Continue";
    version = "1.0.0";
    schema = "v1";
    models = [
      {
        name = "Ollama Gemma 4 26B A4B 4bit MLX";
        provider = "ollama";
        model = ollamaModel;
        apiBase = ollamaApiBase;
        roles = [
          "chat"
          "edit"
          "apply"
          "autocomplete"
        ];
        requestOptions = {
          extraBodyProperties = {
            think = false;
          };
        };
        defaultCompletionOptions = {
          contextLength = 16384;
          maxTokens = 512;
          temperature = 0.2;
          topP = 0.95;
        };
        autocompleteOptions = {
          disable = false;
          debounceDelay = 250;
          maxPromptTokens = 2048;
          modelTimeout = 500;
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

  home.file.".continue/config.yaml".source =
    yamlFormat.generate "continue-config.yaml" continueConfig;

  home.file.".gemini/settings.json".text = builtins.toJSON {
    ide = {
      hasSeenNudge = true;
      enabled = true;
    };
    model = {
      name = "gemini-3.1-preview";
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
    ollamaService
    pkgs-unstable.ollama
    pkgs-unstable.shell-gpt
  ];
}
