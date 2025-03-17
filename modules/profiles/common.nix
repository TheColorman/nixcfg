# Common configuration, assumed to be imported in all hosts
{
  lib,
  inputs,
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
      It's used in custom modules to allow them to be imported by any user. This module is used as a dependency of any module that requires home-manager.
    '';
  };

  config = {
    # flakification
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" username];
    };

    # Allow execution of dynamic binaries
    programs.nix-ld.enable = true;
    nixpkgs.config.allowUnfree = true;

    # Dynamic symlinks in /bin, useful for shebangs
    services.envfs.enable = true;

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
