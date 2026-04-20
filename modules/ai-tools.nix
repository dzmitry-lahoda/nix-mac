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
      - name: LM Studio Qwen3 Coder 30B
        provider: lmstudio
        model: qwen/qwen3-coder-30b
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

  home.packages = [
    codex-cli-nix.packages.${system}.codex
    pkgs-unstable.gemini-cli
  ]
  ++ (with pkgs-lmstudio; [
    lmstudio
  ]);
}
