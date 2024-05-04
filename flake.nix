{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fw-ectool = {
      url = "path:./modules/nixos/fw-ectool";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    fw-ectool,
    ...
  } @ inputs: {
    nixosConfigurations.colornix = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {inherit inputs system;};

      modules = [
        ./hosts/colornix/configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}
