{
  description = "Framework configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fw-ectool.url = "git+file:.?dir=modules/nixos/fw-ectool";
    fw-ectool.inputs.nixpks.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, fw-ectool }@inputs: {
    nixosConfiguration.colornix = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs system; };
      
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        nixos-hardware.nixosModules.framework-13-7040-amd
      ];
    };
  };
}
