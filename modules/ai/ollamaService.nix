{
  pkgs,
  ollama,
  gemmaModel,
  modelfile,
}:

let
  modelName = "gemma-4-26b-a4b-it-4bit-mlx:latest";
in
pkgs.writeShellApplication {
  name = "ollamaService";
  runtimeInputs = [
    ollama
    pkgs.curl
  ];
  text = ''
    set -euo pipefail

    model_name="''${OLLAMA_MODEL_NAME:-${modelName}}"
    ollama_host="''${OLLAMA_HOST:-127.0.0.1:11434}"
    ollama_base_url="http://$ollama_host"

    if ! curl --fail --silent --show-error "$ollama_base_url/api/version" >/dev/null; then
      OLLAMA_HOST="$ollama_host" ollama serve >/tmp/ollama-gemma-4-26b-a4b-it-4bit-mlx.log 2>&1 &
    fi

    retries=60
    while [ "$retries" -gt 0 ]; do
      if curl --fail --silent --show-error "$ollama_base_url/api/version" >/dev/null; then
        break
      fi
      retries=$((retries - 1))
      sleep 2
    done

    curl --fail --silent --show-error "$ollama_base_url/api/version" >/dev/null

    OLLAMA_HOST="$ollama_host" ollama create "$model_name" --file ${modelfile}

    curl --fail --silent --show-error "$ollama_base_url/api/generate" \
      --header "Content-Type: application/json" \
      --data '{"model":"'"$model_name"'","prompt":"","stream":false,"keep_alive":"24h","options":{"num_ctx":16384,"num_batch":1024,"num_gpu":999,"temperature":0.2,"top_p":0.95,"repeat_penalty":1.05,"num_predict":1}}' \
      >/dev/null

    echo "Loaded $model_name from ${gemmaModel}"
  '';
}
