/**
Creates a NixOS configuration using format shared by all hosts.
*/
{lib}: rec {
  mkServant = {
    flake,
    name,
    platform,
    extraModules ? [],
  }:
    lib.nixosSystem {
      specialArgs = {
        inherit (flake) inputs outputs;
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
    flake,
    servants ? {},
  }:
    builtins.mapAttrs (name: servant:
      mkServant {
        inherit flake;
        inherit name;
        inherit (servant) platform;
        extraModules = servant.extraModules or [];
      })
    servants;
}
