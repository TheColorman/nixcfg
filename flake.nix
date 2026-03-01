{
  description = "Colorman NixOS configuration flake";

  outputs = inputs:
  # Create a flake-parts module..
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    # ..by taking the current directory..
    (./.
      # ..and importing the entire filetree..
      |> inputs.import-tree.filterNot
      # ..except the `flake.nix` file itself
      (inputs.nixpkgs.lib.hasSuffix "flake.nix"));

  inputs = {
    # == Primary modules ==
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # == Add-ons ==
    stylix = {
      # Theming
      url = "github:nix-community/stylix/master";
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
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # == Packages provided as flakes ==
    # My nvf config
    nvfcfg.url = "github:TheColorman/nvfcfg";

    # Binary debugger
    pwndbg = {
      url = "github:pwndbg/pwndbg/dev";
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

    # Fish jj plugin
    fish-plugin-jj = {
      url = "github:TheColorman/plugin-jj";
      flake = false;
    };

    # Deployment tooling
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Port exposer for games
    playit-nixos-module = {
      url = "github:pedorich-n/playit-nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Grab unstable git version of nom
    nix-output-monitor = {
      url = "github:maralorn/nix-output-monitor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ZFS dashbaord - not following nixpkgs due to dependency issues
    zfdash-nix-flake.url = "github:TheColorman/zfdash-nix-flake";

    # Authentik packaged as a NixOS module instead of a Docker image
    authentik-nix.url = "github:nix-community/authentik-nix";

    # Free Photoshop-like program by Canva
    affinity-nix = {
      url = "github:mrshmllow/affinity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Anchorr arr discord bot
    anchorr = {
      url = "github:TheColorman/anchorr-nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };
}
