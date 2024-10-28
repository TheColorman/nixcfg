{
  description = "Colorman NixOS configuration flake";

  inputs = {
    nixpkgs.url = "git+file:./dependencies/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
    this = {
      url = "git+file:.";
      flake = false;
    };
  };

  outputs = {
    home-manager,
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
    };
  };
}
