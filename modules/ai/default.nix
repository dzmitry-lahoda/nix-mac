{
  lib,
  pkgs,
  pkgs-unstable,
  codex-cli-nix,
  hermes-agent,
  antigravity-nix,
  agy-conductor,
  agy-postgres,
  codex-agy-plugin,
  trailofbits-skills,
  trailofbits-ask-questions,
  trailofbits-skills-curated,
  dba-review,
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
  tomlFormat = pkgs.formats.toml { };
  yamlFormat = pkgs.formats.yaml { };
  ollamaApiBase = localAi.ollamaApiBase;
  ollamaModel = localAi.ollamaModel;
  defaultLocal = localAi.defaultLocal;
  geminiModel = "gemini-3.1-pro";
  codex = codex-cli-nix.packages.${system}.codex;
  codexGemini = pkgs.writeShellApplication {
    name = "codex-gemini";
    text = ''
      exec ${codex}/bin/codex \
        --config model_provider=openrouter \
        --model '~google/gemini-flash-latest' \
        "$@"
    '';
  };
  codex-this = pkgs.callPackage ./codex-this.nix { inherit codex; };
  sharedAgentSkills = {
    ask-questions-if-underspecified = "${trailofbits-ask-questions}/plugins/ask-questions-if-underspecified/skills/ask-questions-if-underspecified";
    differential-review = "${trailofbits-skills}/plugins/differential-review/skills/differential-review";
    fp-check = "${trailofbits-skills}/plugins/fp-check/skills/fp-check";
    property-based-testing = "${trailofbits-skills}/plugins/property-based-testing/skills/property-based-testing";
    second-opinion = "${trailofbits-skills}/plugins/second-opinion/skills/second-opinion";
    modern-python = "${trailofbits-skills}/plugins/modern-python/skills/modern-python";
    supply-chain-risk-auditor = "${trailofbits-skills}/plugins/supply-chain-risk-auditor/skills/supply-chain-risk-auditor";
    planning-with-files = "${trailofbits-skills-curated}/plugins/planning-with-files/skills/planning-with-files";
    openai-gh-fix-ci = "${trailofbits-skills-curated}/plugins/openai-gh-fix-ci/skills/openai-gh-fix-ci";
    dba-review = dba-review;
  };
  agySharedSkills = pkgs.linkFarm "agy-codex-skills" [
    {
      name = "plugin.json";
      path = pkgs.writeText "agy-codex-skills-plugin.json" (
        builtins.toJSON {
          name = "codex-skills";
          description = "Shared Codex and Antigravity coding skills";
        }
      );
    }
    {
      name = "skills";
      path = pkgs.linkFarm "agy-codex-skill-entries" (
        lib.mapAttrsToList (name: path: { inherit name path; }) sharedAgentSkills
      );
    }
  ];
  strandRustCoderModel =
    pkgs.callPackage ./models/fortytwo-network-strand-rust-coder-14b-v1/weights.nix
      { };
  strandRustCoderModelfile =
    pkgs.callPackage ./models/fortytwo-network-strand-rust-coder-14b-v1/modelfile.nix
      {
        inherit strandRustCoderModel;
      };
  ollamaService = pkgs.callPackage ./ollamaService.nix {
    ollama = pkgs-unstable.ollama;
    modelName = ollamaModel;
  };
  ollamaPreload = pkgs.writeShellApplication {
    name = "ollamaPreload";
    runtimeInputs = [
      pkgs.curl
      pkgs-unstable.ollama
    ];
    text = ''
      set -euo pipefail

      model_name="''${OLLAMA_MODEL_NAME:-${ollamaModel}}"
      ollama_host="''${OLLAMA_HOST:-${localAi.ollamaHost}}"
      ollama_base_url="http://$ollama_host"

      retries=60
      while [ "$retries" -gt 0 ]; do
        if curl --fail --silent --show-error "$ollama_base_url/api/version" >/dev/null; then
          break
        fi
        retries=$((retries - 1))
        sleep 2
      done

      curl --fail --silent --show-error "$ollama_base_url/api/version" >/dev/null

      if ! OLLAMA_HOST="$ollama_host" ollama show "$model_name" >/dev/null 2>&1; then
        OLLAMA_HOST="$ollama_host" ollama create "$model_name" --file ${strandRustCoderModelfile}
      fi

      curl --fail --silent --show-error "$ollama_base_url/api/generate" \
        --header "Content-Type: application/json" \
        --data '{"model":"'"$model_name"'","prompt":"","stream":false,"keep_alive":"-1"}' \
        >/dev/null
    '';
  };
  codexConfig = {
    personality = "pragmatic";
    model = "gpt-5.6-sol";

    model_providers.openrouter = {
      name = "OpenRouter";
      base_url = "https://openrouter.ai/api/v1";
      env_key = "OPENROUTER_API_KEY";
    };

    agents = {
      max_threads = 8;
      max_depth = 3;
      job_max_runtime_seconds = 1800;
    };

    projects = {
      "/Users/dz/overlay/github.com/dzmitry-lahoda/nix-mac".trust_level = "trusted";
      "/Users/dz/overlay/github.com/n1xyz/proton".trust_level = "trusted";
      "/Users/dz/Downloads".trust_level = "trusted";
      "/Users/dz/overlay/github.com/keanemind/jjk".trust_level = "trusted";
      "/Users/dz/overlay/github.com/dzmitry-lahoda/rowview".trust_level = "trusted";
      "/Users/dz/overlay/github.com/jhpratt/deranged".trust_level = "trusted";
    };

    marketplaces.codex-agy-plugin = {
      source_type = "local";
      source = "${codex-agy-plugin}";
    };

    plugins = {
      "google-calendar@openai-curated".enabled = true;
      "gmail@openai-curated".enabled = true;
      "slack@openai-curated".enabled = true;
      "github@openai-curated".enabled = true;
      "codex-agy-plugin@codex-agy-plugin".enabled = true;
    };

    apps.connector_76869538009648d5b282a4bb21c3d157.tools.github_create_pull_request.approval_mode =
      "approve";
  };
  shellGptConfig = {
    OPENAI_API_KEY = "ollama";
    API_BASE_URL = "${ollamaApiBase}/v1";
    DEFAULT_MODEL = defaultLocal;
    USE_LITELLM = false;
    OPENAI_USE_FUNCTIONS = false;
  };
  continueConfig = {
    name = "Local Continue";
    version = "1.0.0";
    schema = "v1";
    models = [
      {
        name = "defaultLocal";
        provider = "ollama";
        model = defaultLocal;
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
  home.file =
    lib.mapAttrs' (
      name: source:
      lib.nameValuePair ".codex/skills/${name}" {
        inherit source;
        force = true;
      }
    ) sharedAgentSkills
    // {
      ".codex/config.toml".source = tomlFormat.generate "codex-config.toml" codexConfig;
      ".codex/plugins/cache/codex-agy-plugin/codex-agy-plugin/0.1.11" = {
        source = "${codex-agy-plugin}/plugins/codex-agy-plugin";
        recursive = true;
      };
      ".codex/skills/agy".source = "${codex-agy-plugin}/plugins/codex-agy-plugin/skills/agy";
      ".gemini/config/plugins/conductor".source = agy-conductor;
      ".gemini/config/plugins/postgres".source = agy-postgres;
      ".gemini/config/plugins/codex-skills".source = agySharedSkills;
      ".config/shell_gpt/.sgptrc".text = lib.generators.toKeyValue { } shellGptConfig;
    };

  # home.file.".continue/config.yaml".source =
  #   yamlFormat.generate "continue-config.yaml" continueConfig;

  launchd.agents.ollamaService = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${ollamaService}/bin/ollamaService"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      EnvironmentVariables = {
        OLLAMA_HOST = localAi.ollamaHost;
        OLLAMA_KEEP_ALIVE = "-1";
      };
    };
  };

  launchd.agents.ollamaPreload = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${ollamaPreload}/bin/ollamaPreload"
      ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
      };
      ProcessType = "Background";
      StandardOutPath = "/tmp/ollama-preload.log";
      StandardErrorPath = "/tmp/ollama-preload.log";
      EnvironmentVariables = {
        OLLAMA_HOST = localAi.ollamaHost;
        OLLAMA_KEEP_ALIVE = "-1";
      };
    };
  };

  home.packages = [
    codex
    codexGemini
    codex-this
    hermes-agent.packages.${system}.default
    antigravity-nix.packages.${system}.google-antigravity-cli
    pkgs.nodejs
    pkgs-unstable.goose-cli
    pkgs-unstable.ollama
    pkgs-unstable.shell-gpt
  ];
}
