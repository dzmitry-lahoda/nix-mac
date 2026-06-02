{ pkgs-unstable, ... }:

let
  typst = pkgs-unstable.typst.withPackages (
    ps: with ps; [
      pintorita
    ]
  );
in
{
  home.packages = with pkgs-unstable; [
    typst
    typst-live
    typstyle
    tinymist

    plantuml-c4
    graphviz
  ];
}
