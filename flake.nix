{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "/home/color/nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "/home/color/nixos/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # configurations
    # TODO: dynamically import host configurations
    framework = {
      url = "path:./hosts/framework";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    globals.url = "path:./globals";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    framework,
    globals,
    ...
  } @ inputs: {
    nixosConfigurations = {
      framework = nixpkgs.lib.nixosSystem (globals.config // framework.config);
    };
  };
}
