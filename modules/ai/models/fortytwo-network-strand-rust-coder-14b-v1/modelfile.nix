{ pkgs, strandRustCoderModel }:

pkgs.writeText "strand-rust-coder-14b-v1.Modelfile" ''
  FROM ${strandRustCoderModel}

  PARAMETER num_ctx 16384
  PARAMETER num_batch 1024
  PARAMETER num_gpu 999
  PARAMETER temperature 0.2
  PARAMETER top_p 0.95
  PARAMETER repeat_penalty 1.05
  PARAMETER num_predict 512
''
