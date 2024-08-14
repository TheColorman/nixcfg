{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "git+file:./dependencies/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager.url = "github:nix-community/home-manager";

    fw-ectool = {
      url = "git+file:.?dir=flakes/fw-ectool";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = { ... }@inputs:
    let
      outputs = inputs.self.outputs;
    in
    {
      nixosConfigurations = {
        framework = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/framework/configuration.nix outputs.nixosModules.default ];
        };
      };

      homeConfigurations = {
        "color@framework" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/framework/home.nix outputs.homeManagerModules.default ];
        };
      };

      nixosModules.default = ./nixosModules;
      homeManagerModules.default = ./homeManagerModules;
    };
}
