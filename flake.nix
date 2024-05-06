{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #home-manager = {
    #  url = "github:nix-community/home-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #nix-alien = {
    #  url = "github:thiagokokada/nix-alien";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #fw-ectool = {
    #  url = "path:./modules/nixos/fw-ectool";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # configurations
    colornix.url = "path:./hosts/colornix";
  };

  outputs = {
    self,
    nixpkgs,
    #nixos-hardware,
    #fw-ectool,
    colornix,
    ...
  } @ inputs: {
    #nixosConfigurations.colornix = nixpkgs.lib.nixosSystem rec {
    #  system = "x86_64-linux";
    #  specialArgs = {inherit inputs system;};
    #
    #  modules = [
    #    ./hosts/colornix/configuration.nix
    #    inputs.home-manager.nixosModules.default
    #    nixos-hardware.nixosModules.framework-13-7040-amd
    #  ];
    #};
    nixosConfigurations = let
      colornixConfig = builtins.trace colornix colornix.nixosConfigurations;
    in {
      colornix = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs system; suwucide = colornixConfig; };
        modules = [];
      };
    };
  };
}
