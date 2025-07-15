/**
Creates a NixOS configuration using format shared by all hosts.
*/
{lib}: rec {
  mkServant = {
    inputs,
    outputs,
    name,
    platform,
    extraModules ? [],
  }:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
        systemName = name;
        systemPlatform = platform;
      };
      modules =
        [
          ../hosts/${name}/configuration.nix
        ]
        ++ extraModules;
    };

  mkServants = {
    inputs,
    outputs,
    servants ? {},
  }:
    builtins.mapAttrs (name: servant:
      mkServant {
        inherit inputs outputs name;
        inherit (servant) platform;
        extraModules = servant.extraModules or [];
      })
    servants;
}
