{ pkgs-unstable, ... }:

{
  services.syncthing = {
    enable = true;
    package = pkgs-unstable.syncthing;
    settings.options.urAccepted = 1;
  };

  home.packages = [
    pkgs-unstable.syncthing
  ];
}


  # enable = true;
  # openDefaultPorts = true;
  # guiPasswordFile = "/etc/syncthing-gui-password";
  # settings = {
  #   gui.user = "myuser";
  #   devices = {
  #     "device1" = { id = "DEVICE-ID-GOES-HERE"; };
  #     "device2" = { id = "DEVICE-ID-GOES-HERE"; };
  #   };
  #   folders = {
  #     "Documents" = {
  #       path = "/home/myusername/Documents";
  #       devices = [ "device1" "device2" ];
  #     };
  #     "Example" = {
  #       path = "/home/myusername/Example";
  #       devices = [ "device1" ];
  #       ignorePerms = false; # Enable file permission syncing
  #     };
  #   };
  # };