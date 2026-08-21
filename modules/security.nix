{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.bash.sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

  launchd.agents.secretive = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs-unstable.secretive}/Applications/Secretive.app/Contents/MacOS/Secretive"
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  home.packages = [
    pkgs-unstable.secretspec
    pkgs-unstable.secretive
  ];
}
