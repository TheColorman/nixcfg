{
  description = "Colorman NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-24-05.url = "github:nix-community/home-manager/release-24.05";
    home-manager-24-05.inputs.nixpkgs.follows = "nixpkgs-24-05";

    stylix = {
      url = "github:danth/stylix?ref=release-24.05";
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
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs-24-05";
  };

  outputs = {
    home-manager,
    home-manager-24-05,
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
        };
        modules = [
          ./hosts/framework/configuration.nix
          home-manager.nixosModules.default
          nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };

      boarding = inputs.nixpkgs-24-05.lib.nixosSystem {
        specialArgs = let
          # @TODO: This is goofy as hell, needs to be refactored.
          # Figure out how to get profels/common to import preferred modules.
          boardingInputs =
            (builtins.removeAttrs inputs ["nixpkgs" "home-manager"])
            // {
              nixpkgs = inputs.nixpkgs-24-05;
              home-manager = inputs.home-manager-24-05;
            };
        in {
          inherit outputs;
          inputs = boardingInputs;
        };
        modules = [
          ./hosts/boarding/configuration.nix
          home-manager-24-05.nixosModules.default
        ];
      };
    };
  };
}
