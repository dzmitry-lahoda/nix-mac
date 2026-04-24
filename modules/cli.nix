{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:

{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    package = pkgs-unstable.atuin;
  };

  programs.starship = {
    enable = true; # not sure if i need it a all - it also lack shortened path
    enableBashIntegration = true;
    package = pkgs.starship;
    settings = {
      # directory = {
      #     truncation_length = 2;
      #     truncation_symbol = "…/";
      # };
      add_newline = false;
      # assumes i do not need all infor on each line
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$shlvl"
        "$singularity"
        "$kubernetes"
        "$directory"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$custom"
        "$sudo"
        "$jobs"
        "$status"
        "$os"
        "$container"
        "$netns"
        "$shell"
        "$character"
      ];
      custom.jj_bookmark = {
        command = "${pkgs-unstable.jujutsu}/bin/jj log -r 'latest(ancestors(@) & bookmarks())' --no-graph -T 'bookmarks.join(\" \")'";
        when = "test -n \"$(${pkgs-unstable.jujutsu}/bin/jj log -r 'latest(ancestors(@) & bookmarks())' --no-graph -T 'bookmarks.join(\" \")' 2>/dev/null)\"";
        format = "[$symbol$output]($style) ";
        symbol = "jj ";
        style = "purple";
      };
      package.disabled = false;
    };
  };

  home.packages = with pkgs; [
    bat
    bottom
    delta
    dust
    eza
    fd
    procs
    ripgrep
    sd
    skim
    zoxide
  ];
}
