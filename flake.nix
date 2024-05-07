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
    colornix.url = "path:./hosts/colornix";
    colornix.inputs.home-manager.follows = "home-manager";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    colornix,
    ...
  } @ inputs: {
    nixosConfigurations = {
      colornix = nixpkgs.lib.nixosSystem colornix.config;
    };
  };
}
