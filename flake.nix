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
  } @ inputs: 
  let
    overlays = [
      (final: prev: {
        colorectool = fw-ectool.packages.x86_64-linux.default; 
      })
    ];
  in
  {
    nixosConfigurations.colornix = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        ./hosts/colornix/configuration.nix
        inputs.home-manager.nixosModules.default
        ({ pkgs, ... }: {
          nixpkgs.overlays = overlays;
          environment.systemPackages = with pkgs; [ colorectool ];
        })
      ];
    };
  };
}
