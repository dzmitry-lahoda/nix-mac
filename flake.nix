{
  description = "macOS Home Manager + Codex CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
 
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, darwin, ... }:
    let
      system = "aarch64-darwin"; 
      username = "dz";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
    darwinConfigurations = {
      dzs-MacBook-Pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          {
            nix.enable = false;
            nixpkgs.config.allowUnfree = true;
            environment.shells = [ pkgs.bashInteractive ];
            users.users.${username} = {
              home = "/Users/${username}";
              shell = pkgs.bashInteractive;
            };
            system.stateVersion = 2;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit pkgs-unstable;
            };
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };
    };

      apps.${system}.rebuild = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "rebuild";
          text = ''
            exec /usr/bin/sudo ${pkgs.nix}/bin/nix run nix-darwin#darwin-rebuild -- switch --flake .#dzs-MacBook-Pro "$@"
          '';
        }}/bin/rebuild";
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {
          inherit pkgs-unstable;
        };
        modules = [ ./home.nix ];
      };
    };
}
