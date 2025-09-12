{
  description = "Colorman NixOS configuration flake";
  outputs = {
    nixpkgs,
    nixos-hardware,
    self,
    ...
  } @ inputs: let
    cLib = import ./lib {inherit (nixpkgs) lib;};
  in {
    modules = cLib.recurseModules ./.;

    nixosConfigurations = cLib.mkServants {
      inherit inputs;
      inherit (self) outputs;

      servants = {
        # Laptop
        archer = {
          platform = "x86_64-linux";
          extraModules = [
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
        };
        # WSL
        foreigner.platform = "x86_64-linux";

        # rpi 4
        rider = {
          platform = "aarch64-linux";
          extraModules = [
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
        };
        # SD card
        lancer.platform = "x86_64-linux";

        # Desktop
        saber.platform = "x86_64-linux";
      };
    };
  };

  inputs = {
    # == Primary modules ==
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware?ref=master";
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # == Add-ons ==
    stylix = {
      # Theming
      url = "github:danth/stylix/master";
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

    # == Packages provided as flakes ==
    # My nvf config
    nvfcfg.url = "github:TheColorman/nvfcfg";

    # Binary debugger
    pwndbg = {
      url = "github:pwndbg/pwndbg?ref=dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repo
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # discord bot
    factbot = {
      url = "github:TheColorman/factbot";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # other discord bot
    discord-portal = {
      url = "github:TheColorman/discord-portal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop shell dots
    caelestia = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-index with prebuilt databases
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pacman inspired Nix wrapper
    pinix = {
      url = "github:remi-dupre/pinix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
