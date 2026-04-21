{
  pkgs,
  pkgs-unstable,
  pkgs-lmstudio,
  codex-cli-nix,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.file.".continue/config.yaml".text = ''
    name: Local Continue
    version: 1.0.0
    schema: v1

    models:
      - name: lmstudio hesamation/Qwen3.6-35B-A3B-Claude-4.6-Opus-Reasoning-Distilled
        provider: lmstudio
        model: hesamation/Qwen3.6-35B-A3B-Claude-4.6-Opus-Reasoning-Distilled
        apiBase: http://localhost:1234/v1
        roles:
          - chat
          - edit
          - apply
          - autocomplete
        autocompleteOptions:
          disable: false
          debounceDelay: 250
          maxPromptTokens: 1024
          modelTimeout: 150
          maxSuffixPercentage: 0.2
          prefixPercentage: 0.3
          onlyMyCode: true
  '';

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
  ]
  ++ (with pkgs-lmstudio; [
    lmstudio
  ]);
}
