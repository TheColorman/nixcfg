{ lib, config, pkgs, inputs, outputs, ... }:
let
  cfg = config.myNixOS;
in
{
  imports = [ ];

  options.myNixOS = {
    username = lib.mkOption {
      default = "color";
      description = "username";
    };
    userConfig = lib.mkOption {
      default = ../../hosts/framework/home.nix;
      description = "User configuration";
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      extraSpecialArgs = {
        inherit inputs;
        outputs = inputs.self.outputs;
      };
      users = {
        ${cfg.username} = { ... }: {
          imports = [
            (import cfg.userConfig)
            outputs.homeManagerModules.default
          ];
        };
      };
    };
  };
}
