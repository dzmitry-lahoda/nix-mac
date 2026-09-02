{
  description = "macOS Home Manager + Codex CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-ivpn.url = "github:NixOS/nixpkgs?ref=pull/542306/head";
    zed.url = "github:zed-industries/zed";
    zed.inputs.nixpkgs.follows = "nixpkgs";
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    agy-conductor = {
      url = "github:gemini-cli-extensions/conductor";
      flake = false;
    };
    agy-postgres = {
      url = "github:gemini-cli-extensions/postgres";
      flake = false;
    };
    codex-agy-plugin = {
      url = "github:sysCat64/codex-agy-plugin";
      flake = false;
    };
    trailofbits-skills = {
      url = "github:trailofbits/skills";
      flake = false;
    };
    trailofbits-ask-questions = {
      url = "github:trailofbits/skills/d5fe2e6a7896236c3102fd5477e833623ad70298";
      flake = false;
    };
    trailofbits-skills-curated = {
      url = "github:trailofbits/skills-curated";
      flake = false;
    };
    dba-review = {
      url = "github:dhdtech/dba-review";
      flake = false;
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-ivpn,
      zed,
      codex-cli-nix,
      hermes-agent,
      antigravity-nix,
      agy-conductor,
      agy-postgres,
      codex-agy-plugin,
      trailofbits-skills,
      trailofbits-ask-questions,
      trailofbits-skills-curated,
      dba-review,
      rust-overlay,
      home-manager,
      darwin,
      ...
    }:
    let
      system = "aarch64-darwin";
      username = "dz";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ rust-overlay.overlays.default ];
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true; # some cuda modules loaded by AI, not used
        overlays = [ rust-overlay.overlays.default ];
      };
      pkgs-ivpn = import nixpkgs-ivpn {
        inherit system;
        # config.allowUnfree = true;
        # config.allowUnsupportedSystem = true;
      };

      gemmaModel =
        pkgs.callPackage ./modules/ai/models/mlx-community-gemma-4-26b-a4b-it-4bit-mlx/weights.nix
          { };
      gemmaModelfile =
        pkgs.callPackage ./modules/ai/models/mlx-community-gemma-4-26b-a4b-it-4bit-mlx/modelfile.nix
          { inherit gemmaModel; };
      strandRustCoderModel =
        pkgs.callPackage ./modules/ai/models/fortytwo-network-strand-rust-coder-14b-v1/weights.nix
          { };
      strandRustCoderModelfile =
        pkgs.callPackage ./modules/ai/models/fortytwo-network-strand-rust-coder-14b-v1/modelfile.nix
          { inherit strandRustCoderModel; };
      ollamaService = pkgs.callPackage ./modules/ai/ollamaService.nix {
        ollama = pkgs-unstable.ollama;
        model = strandRustCoderModel;
        modelName = "fortytwo-network-strand-rust-coder-14b-v1:latest";
        modelfile = strandRustCoderModelfile;
      };
    in
    {
      darwinConfigurations = {
        dzs-MacBook-Pro = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.home-manager
            {
              nix.enable = false;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              # system.primaryUser = username;
              # homebrew.enable = true;
              # homebrew.casks = [ "ledger-live" ];
              programs.bash.enable = true;
              environment.shells = [ pkgs.bashInteractive ];
              # environment.systemPackages = with pkgs; [
              #   llvmPackages.clang
              # ];
              users.users.${username} = {
                home = "/Users/${username}";
                shell = pkgs.bashInteractive;
              };
              system.activationScripts.installRosetta.text = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isAarch64 ''
                if /usr/sbin/pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
                  echo "Rosetta 2 already installed"
                else
                  echo "Installing Rosetta 2..."
                  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
                fi
              '';
              system.stateVersion = 2;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit pkgs-unstable pkgs-ivpn;
                inherit zed;
                inherit codex-cli-nix;
                inherit hermes-agent;
                inherit antigravity-nix;
                inherit agy-conductor agy-postgres codex-agy-plugin;
                inherit
                  trailofbits-skills
                  trailofbits-ask-questions
                  trailofbits-skills-curated
                  dba-review
                  ;
              };
              home-manager.users.${username} = import ./home.nix;
            }
          ];
        };
      };

      apps.${system} = {
        rebuild = {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "rebuild";
              text = ''
                set -euo pipefail

                # if ! ${pkgs.git}/bin/git diff --quiet || ! ${pkgs.git}/bin/git diff --cached --quiet; then
                #   echo "Refusing to rebuild: commit or stash your changes first." >&2
                #   exit 1
                # fi

                echo "Rebuilding system configuration..."

                /usr/bin/sudo ${pkgs.nix}/bin/nix run nix-darwin#darwin-rebuild -- switch --flake .#dzs-MacBook-Pro "$@"

                desired_shell=/run/current-system/sw/bin/bash
                current_shell="$(/usr/bin/dscl . -read /Users/${username} UserShell 2>/dev/null | /usr/bin/awk '{ print $2 }')"

                if [ "$current_shell" != "$desired_shell" ]; then
                  /usr/bin/chsh -s "$desired_shell"
                fi
              '';
            }
          }/bin/rebuild";
        };

        check = {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "check";
              text = ''
                set -euo pipefail
                ${pkgs.nix}/bin/nix flake check
                ${pkgs.nix}/bin/nix build .#homeConfigurations.${username}.config.home.path --no-link
              '';
            }
          }/bin/check";
        };
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {
          inherit pkgs-unstable pkgs-ivpn;
          inherit zed;
          inherit codex-cli-nix;
          inherit hermes-agent;
          inherit antigravity-nix;
          inherit agy-conductor agy-postgres codex-agy-plugin;
          inherit
            trailofbits-skills
            trailofbits-ask-questions
            trailofbits-skills-curated
            dba-review
            ;
        };
        modules = [ ./home.nix ];
      };

      packages.${system} = {
        inherit ollamaService;
        inherit strandRustCoderModel;
        inherit strandRustCoderModelfile;
        check = pkgs.libllvm;
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };

  # i have fast enough machine, so no really need it
  # nixConfig = {
  #   extra-substituters = [
  #     "https://zed.cachix.org"
  #     "https://cache.garnix.io"
  #   ];
  #   extra-trusted-public-keys = [
  #     "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
  #     "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  #   ];
  # };
}
