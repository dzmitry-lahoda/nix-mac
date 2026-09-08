{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  codex-cli-nix,
  hermes-agent,
  antigravity-nix,
  agy-conductor,
  agy-postgres,
  codex-agy-plugin,
  agent-skills-nix,
  trailofbits-skills,
  trailofbits-skills-curated,
  dba-review,
  awesome-copilot,
  agentic-awesome-skills,
  wshobson-agents,
  caveman,
  i-have-adhd,
  asd-ste100-skill,
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
  agyModel = "Gemini 3.8 Flash (High)";
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

  # Select source roots; agent-skills-nix discovers every nested SKILL.md.
  skillSources =
    lib.genAttrs
      [
        "modern-python"
        "code-improver"
        "spec-to-code-compliance"
        "fp-check"
        "property-based-testing"
        "mutation-testing"
        "rust-review"
        "second-opinion"
        "supply-chain-risk-auditor"
        "audit-context-building"
        "differential-review"
        "dimensional-analysis"
        "trailmark"
      ]
      (name: {
        path = "${trailofbits-skills}/plugins/${name}/skills";
      })
    //
      lib.genAttrs
        [
          "planning-with-files"
          "openai-gh-fix-ci"
        ]
        (name: {
          path = "${trailofbits-skills-curated}/plugins/${name}/skills";
        })
    //
      lib.genAttrs
        [
          "sql-code-review"
          "postgresql-code-review"
          "postgresql-optimization"
        ]
        (name: {
          path = "${awesome-copilot}/skills/${name}";
        })
    //
      lib.genAttrs
        [
          "database-migrations-sql-migrations"
          "postgresql"
        ]
        (name: {
          path = "${agentic-awesome-skills}/skills/${name}";
        })
    // {
      i-have-adhd.path = "${i-have-adhd}/skills";
      caveman.path = "${caveman}/skills";
      asd-ste100-skill.path = asd-ste100-skill;
      dba-review.path = dba-review;
      agy.path = "${codex-agy-plugin}/plugins/codex-agy-plugin/skills";
      sql-optimization-patterns.path = "${wshobson-agents}/plugins/developer-essentials/skills/sql-optimization-patterns";
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
      path = config.programs.agent-skills.bundlePath;
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
    model = "gpt-6-astra";

    model_providers.openrouter = {
      name = "OpenRouter";
      base_url = "https://openrouter.ai/api/v1";
      env_key = "OPENROUTER_API_KEY";
    };

    agents = {
      max_concurrent_threads_per_session = 8;
      max_depth = 4;
      background_terminal_max_timeout = 900000; # millis
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
  imports = [ agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;
    sources = lib.mapAttrs (
      _: source:
      source
      // {
        filter.maxDepth = null;
      }
    ) skillSources;
    skills.enableAll = true;
    targets = {
      codex = {
        enable = true;
        dest = ".codex/skills";
        structure = "link";
      };
      antigravity = {
        enable = true;
        dest = ".gemini/antigravity/skills";
        structure = "link";
      };
    };
  };

  home.file = {
    ".codex/config.toml".source = tomlFormat.generate "codex-config.toml" codexConfig;
    ".gemini/antigravity-cli/settings.json".text = builtins.toJSON {
      allowNonWorkspaceAccess = true;
      model = agyModel;
      permissions.allow = [
        "command(git clone)"
        "command(git fetch)"
        "command(git checkout)"
        "command(git show)"
        "command(git log)"
        "command(git diff)"
        "command(nix)"
        "command(lsof)"
        "command(ps)"
        "command(grep)"
        "command(psql)"
        "command(env)"
        "command(cat)"
        "command(xargs)"
        "command(diff)"
        "command(git status)"
        "command(z)"
        "command(git restore)"
        "command(git grep)"
        "command(git merge-base)"
        "command(gh)"
        "command(mkdir)"
        "command(ls)"
        "command(git worktree)"
        "command(pkill)"
        "command(fd)"
        "command(sd)"
        "command(fzf)"
        "command(cp)"
        "command(sleep)"
        "command(docker ps)"
        "command(cargo update)"
        "command(git branch)"
        "command(git add)"
        "command(git commit)"
        "command(git rev-parse)"
        "command(head)"
        "command(mv)"
        "command(wait)"
        "command(agy)"
        "command(which)"
        "command(darwin-rebuild)"
        "command(date)"
        "command(pwd)"
        "command(curl)"
        "command(cargo init --lib)"
        "command(cargo test)"
        "command(cargo check --tests)"
        "command(cargo check --all-targets)"
        "command(cargo check)"
        "command(git pull)"
        "command(git remote)"
        "command(magic)"
        "command(git reflog)"
        "command(jj status)"
        "command(jj log)"
        "command(jj bookmark)"
      ];
      trustedWorkspaces = [ "/Users/dz/overlay/github.com" ];
    };
    ".codex/plugins/cache/codex-agy-plugin/codex-agy-plugin/0.1.11" = {
      source = "${codex-agy-plugin}/plugins/codex-agy-plugin";
      recursive = true;
    };
    # Keep rust-review's scripts, prompts, and agent definitions discoverable by its fallback search.
    ".codex/plugins/rust-review" = {
      source = "${trailofbits-skills}/plugins/rust-review";
      recursive = true;
    };
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
