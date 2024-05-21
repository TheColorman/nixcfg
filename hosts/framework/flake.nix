{
  description = "Framework configuration";

  inputs = {
    nixpkgs.url = "/home/color/nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "/home/color/nixos/nixos-hardware?ref=master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fw-ectool.url = "git+file:.?dir=modules/flakes/fw-ectool";
    fw-ectool.inputs.nixpkgs.follows = "nixpkgs";

    this.url = "git+file:.";
    this.flake = false;
  };

  outputs = {
    self, nixpkgs, nixos-hardware, home-manager, fw-ectool, this
  }@inputs: {
    config = rec {
      system = "x86_64-linux";
      specialArgs = { inherit inputs system; };

      modules = [
        ./configuration.nix
        
        inputs.home-manager.nixosModules.default
        nixos-hardware.nixosModules.framework-13-7040-amd

        # I can't import the nix configs directly since they're in a parent
        # directory, so guess I'm forced to treat them all as non-flake inputs
        # and import them by referencing the parent flake output path like this.
      ] ++ nixpkgs.lib.imap0 (i: v: "${this.outPath}/modules/nixos/${v}.nix") [
        "plasma" # Desktop environment
        "bootloader" # Generic bootloader - grub tbd
        "locale" # Danish UTF-8 locale for rendering
        "networking" # Networkmanager
        "nix" # General nixos config
        "shell" # Global zsh, might make this user-based for home-manager management
        "snix" # Script used to version control nix config
      ];
    };
  };
}
