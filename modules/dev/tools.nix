{
  pkgs,
  pkgs-unstable,
  ...
}:

let
  rust = pkgs.rust-bin.fromRustupToolchainFile ../../rust-toolchain.toml;
  rustCToolchain = import ./native-toolchain.nix { inherit pkgs; };
  python = pkgs-unstable.python315.withPackages (
    ps: with ps; [
      # beautifulsoup4
      # bokeh
      # dash
      # datasets
      # geopandas
      # gradio
      # graphviz
      # imageio
      # ipython
      # jupyter
      # jupyterlab
      # langchain
      # matplotlib
      # networkx
      # numpy
      # ocrmypdf
      # opencv4
      # openai
      # pandas
      # pdf2image
      # pdfminer-six
      # pdfplumber
      # pillow
      # plotly
      # polars
      # pyarrow
      # pymupdf
      # pypdf
      # pypdfium2
      # pytesseract
      # requests
      # scikit-image
      # scikit-learn
      # scipy
      # seaborn
      # sentence-transformers
      # setuptools
      # statsmodels
      # streamlit
      # sympy
      # textual
      # torch
      # torchvision
      # transformers
      # typer
      # virtualenv
      # wheel
    ]
  );
in
{
  home.packages =
    rustCToolchain.packages
    ++ (with pkgs; [
      android-tools
      cargo-cache
      git
      git-lfs
      act
      openssh
      rust
      gita
    ])
    ++ (with pkgs-unstable; [
      graphviz
      helix
      jjui
      lazyjj
      lean4
      mermaid-cli
      openai-whisper
      poppler
      pijul
      sqlx-cli
      process-compose
      python
      # swift
      tesseract
      uv
      #visidata
      zellij
      zig
    ]);
}
