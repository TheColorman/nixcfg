{
  description = "Colorman NixOS configuration flake";

  inputs = {
    # == Important modules ==
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/3d9b0a86d74e9dc3a85ed8d2abcef3ab0940c69d";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # == Add-ons ==
    # Theming
    stylix.url = "github:danth/stylix?ref=release-24.11";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-secrets.url = "git+ssh://git@github.com/TheColorman/nix-secrets?shallow=1";
    nix-secrets.flake = false;
    # WSL
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # == Packages only provided as flake ==
    # My nixvim config
    nixvimcfg.url = "github:TheColorman/nixvimcfg";
    nixvimcfg.inputs.nixpkgs.follows = "nixpkgs";
    # Binary debugger
    pwndbg.url = "github:pwndbg/pwndbg?ref=dev";
    pwndbg.inputs.nixpkgs.follows = "nixpkgs";
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
          systemName = "framework";
        };
        modules = [
          ./hosts/framework/configuration.nix
          home-manager.nixosModules.default
          nixos-hardware.nixosModules.framework-13-7040-amd
        ];
      };

      boarding = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          ./hosts/boarding/configuration.nix
          home-manager.nixosModules.default
        ];
      };

      live = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          systemName = "live";
        };
        modules = [
          ./hosts/live/configuration.nix
          home-manager.nixosModules.default
        ];
      };
    };

    build.live = inputs.self.outputs.nixosConfigurations.live.config.system.build.images.sd-card;
  };
}
