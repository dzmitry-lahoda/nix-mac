{
  pkgs,
  ollama,
  modelName,
  ...
}:

let
  logName = builtins.replaceStrings [ ":" "/" ] [ "-" "-" ] modelName;
in
pkgs.writeShellApplication {
  name = "ollamaService";
  runtimeInputs = [
    ollama
  ];
  text = ''
    set -euo pipefail

    ollama_host="''${OLLAMA_HOST:-127.0.0.1:11434}"

    exec env OLLAMA_HOST="$ollama_host" ollama serve >/tmp/ollama-${logName}.log 2>&1
  '';
}
