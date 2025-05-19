{
  description = "Colorman NixOS configuration flake";

  inputs = {
    # == Important modules ==
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # == Add-ons/modules ==
    stylix = {
      # Theming
      url = "github:danth/stylix/master";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/TheColorman/nix-secrets?shallow=1";
      flake = false;
    };
    # WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Logitech device management
    solaar = {
      url = "github:Svenum/Solaar-Flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # == Packages only provided as flake ==
    # My nvf config
    nvfcfg.url = "github:TheColorman/nvfcfg";

    # Binary debugger
    pwndbg = {
      url = "github:pwndbg/pwndbg?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    home-manager,
    nixos-hardware,
    ...
  } @ inputs: let
    inherit (inputs.self) outputs;
  in {
    modules = import ./lib {
      inherit (inputs.nixpkgs) lib;
    };

    nixosConfigurations = {
      archer = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          systemName = "archer";
        };
        modules = [
          ./hosts/archer/configuration.nix
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
