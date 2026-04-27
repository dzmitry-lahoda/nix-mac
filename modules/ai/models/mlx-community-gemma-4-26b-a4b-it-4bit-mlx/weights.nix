{ pkgs }:

pkgs.fetchgit {
  name = "mlx-community-gemma-4-26b-a4b-it-4bit";
  url = "https://huggingface.co/mlx-community/gemma-4-26b-a4b-it-4bit";
  rev = "695690b33533b1f8b0395c1d6b4f00dc411353ef";
  hash = "sha256-no8mdXcHpaUfZ5Nb+JwjCdbnhzoT97bVuXNbm85JNEA=";
  fetchLFS = true;
}
