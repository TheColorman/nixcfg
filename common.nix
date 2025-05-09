# Common configuration, assumed to be imported in all hosts
{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: let
  inherit (config.my) username;
in {
  imports = [inputs.home-manager.nixosModules.default];

  options.my.username = lib.mkOption {
    default = "color";
    description = ''
      Username used for home-manager configuration.
      It's used in custom modules to allow them to be imported by any user.
      This module is used as a dependency of any module that requires
      home-manager.
    '';
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    nix = {
      settings = {
        # flakes
        experimental-features = ["nix-command" "flakes"];
        # allow main user to trust binary caches among other things
        trusted-users = ["root" username];
      };

      # A flake registry is a repository that contains a nix flake. This
      # attrset specifies system-wide registries and their aliases. For
      # example, the nixpkgs alias, which by default points to
      # github:nixos/nixpkgs/master, is here set to instead point to the
      # nixpkgs revision used in this system flake. This prevents the system
      # from trying to fetch the newest nixpkgs revision every time I try do
      # `nix run nixpkgs#` or `nix shell nixpkgs#`.
      registry = {
        nixpkgs = {
          from = {
            id = "nixpkgs";
            type = "indirect";
          };
          flake = inputs.nixpkgs;
        };
        nur.to = {
          owner = "nix-community";
          repo = "nur";
          type = "github";
        };
      };
    };
    # Allow execution of dynamic binaries
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [libsecret];
    };
    services = {
      envfs.enable = true; # /bin symlinks for shebangs
      printing.enable = true;
    };
    hardware.graphics.enable32Bit = true; # 32-bit application support

    users.mutableUsers = false;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      extraSpecialArgs = {
        inherit inputs;
        inherit (inputs.self) outputs;
      };
      users."${username}" = {
        programs.home-manager.enable = true;
        home = {
          inherit username;
          homeDirectory = "/home/${username}";
          stateVersion = "23.11";
        };
      };
    };
  };
}
