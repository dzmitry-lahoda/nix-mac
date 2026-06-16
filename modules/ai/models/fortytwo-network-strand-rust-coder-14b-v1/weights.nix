{ pkgs }:

let
  repo = "Fortytwo-Network/Strand-Rust-Coder-14B-v1";
  rev = "8fcd66d09811f5130011059bafaf8847243c9afd";

  fetch =
    file: hash:
    pkgs.fetchurl {
      url = "https://huggingface.co/${repo}/resolve/${rev}/${file}";
      inherit hash;
    };

  files = [
    {
      name = "added_tokens.json";
      path = fetch "added_tokens.json" "sha256-WLVLvjb8dS95okonHvZqCggwBUtN+tlL3nV9hRloBgs=";
    }
    {
      name = "chat_template.jinja";
      path = fetch "chat_template.jinja" "sha256-LiTwmEY1edyCCqo4Dl7Jes+fA+vZwj3hfNBYeBdrLu8=";
    }
    {
      name = "config.json";
      path = fetch "config.json" "sha256-GuoQgLuX1+pK+kC1kgXv+GoA0C1R+bfTUg/9rd1/fGw=";
    }
    {
      name = "generation_config.json";
      path = fetch "generation_config.json" "sha256-/XvhNXamUje1nfhlauuK9huUNoZQ4sE64vG6lSZsmOQ=";
    }
    {
      name = "merges.txt";
      path = fetch "merges.txt" "sha256-iDHk8aBERxNA98CoPXvXEwaluGfpX9hw900MUwipBNU=";
    }
    {
      name = "model-00001-of-00006.safetensors";
      path = fetch "model-00001-of-00006.safetensors" "sha256-799fb0Vmt7k9IRR4lldsNlf8fHUIgcGRtjE9h/Y8vzU=";
    }
    {
      name = "model-00002-of-00006.safetensors";
      path = fetch "model-00002-of-00006.safetensors" "sha256-b2IPcZviXn/aovLvApcCXZdbl50m0gRoZUj5SoH+7w8=";
    }
    {
      name = "model-00003-of-00006.safetensors";
      path = fetch "model-00003-of-00006.safetensors" "sha256-2sWY7ltSzEo9XMqEv8YFb5xF663BW32B7GFMQHxEVRc=";
    }
    {
      name = "model-00004-of-00006.safetensors";
      path = fetch "model-00004-of-00006.safetensors" "sha256-Kvp3greg3fTg5XxVeIbl/zCzOooaqsV39oj7TGbuNUA=";
    }
    {
      name = "model-00005-of-00006.safetensors";
      path = fetch "model-00005-of-00006.safetensors" "sha256-4pEP03b9IrHX603u8zQ839kmLZAlHczmqUiSppU9ngg=";
    }
    {
      name = "model-00006-of-00006.safetensors";
      path = fetch "model-00006-of-00006.safetensors" "sha256-a6ATXjtmFg8MSR6WNdYDlt5a4+R/tqCqgzbM52iHW6c=";
    }
    {
      name = "model.safetensors.index.json";
      path = fetch "model.safetensors.index.json" "sha256-/eTp5GaoqTV9ygpNO142VtUo+nGKh1IMalqUkfRT+H0=";
    }
    {
      name = "special_tokens_map.json";
      path = fetch "special_tokens_map.json" "sha256-doYudlJmuFqpRZdn4zy68Tlw8yeg6I0cZYRsLd06Hs0=";
    }
    {
      name = "tokenizer.json";
      path = fetch "tokenizer.json" "sha256-nFrgDmAriGDL14S6gqiqFOj+7OxpLnB2WQ0BTXt/2vo=";
    }
    {
      name = "tokenizer_config.json";
      path = fetch "tokenizer_config.json" "sha256-8G1Ud3pMWcI+1giyUpxJ9qZoU9+byKJU1S7rO5nXyCc=";
    }
    {
      name = "vocab.json";
      path = fetch "vocab.json" "sha256-yhDX6fs+0YV13R4neiV5wW0QjjLydDloSvoOELFECRA=";
    }
  ];
in
pkgs.runCommand "fortytwo-network-strand-rust-coder-14b-v1" { } (
  ''
    mkdir -p "$out"
  ''
  + pkgs.lib.concatMapStringsSep "\n" (file: ''
    cp ${file.path} "$out/${file.name}"
  '') files
)
