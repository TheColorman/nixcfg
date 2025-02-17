{
  description = "Colorman NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-boarder.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-boarder.url = "github:nix-community/home-manager/release-24.11";
    home-manager-boarder.inputs.nixpkgs.follows = "nixpkgs-boarder";

    stylix = {
      url = "github:danth/stylix?ref=release-24.11";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/TheColorman/nix-secrets?shallow=1";
      flake = false;
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs-boarder";
    nixvimcfg.url = "github:TheColorman/nixvimcfg";
    nixvimcfg.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    home-manager,
    home-manager-boarder,
    nixos-hardware,
    ...
  } @ inputs: let
    outputs = inputs.self.outputs;
  in {
    modules = import ./modules {
      lib = inputs.nixpkgs.lib;
    };

    nixosConfigurations = {
      framework = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          systemName = "framework";
        };
        modules = [
          ./hosts/framework/configuration.nix
          home-manager.nixosModules.default
          nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };

      boarding = inputs.nixpkgs-boarder.lib.nixosSystem {
        specialArgs = let
          # @TODO: This is goofy as hell, needs to be refactored.
          # Figure out how to get profels/common to import preferred modules.
          boardingInputs =
            (builtins.removeAttrs inputs ["nixpkgs" "home-manager"])
            // {
              nixpkgs = inputs.nixpkgs-boarder;
              home-manager = inputs.home-manager-boarder;
            };
        in {
          inherit outputs;
          inputs = boardingInputs;
        };
        modules = [
          ./hosts/boarding/configuration.nix
          home-manager-boarder.nixosModules.default
        ];
      };

      live = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          systemName = "live";
        };
        modules = [
          ./hosts/live/configuration.nix
          home-manager.nixosModules.default
        ];
      };
    };

    build.live = inputs.self.outputs.nixosConfigurations.live.config.system.build.images.sd-card;
  };
}
