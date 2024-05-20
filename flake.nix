{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nix-alien = {
    #  url = "github:thiagokokada/nix-alien";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # configurations
    # TODO: dynamically import host configurations
    framework.url = "path:./hosts/framework";
    framework.inputs.home-manager.follows = "home-manager";

    globals.url = "path:./globals";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    framework,
    ...
  } @ inputs: {
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem framework.config;
    };
  };
}
