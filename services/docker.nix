{
  flake.nixosModules.services-docker = {config, ...}: let
    inherit (config.my) username;
  in {
    virtualisation.docker.enable = true;

    users.users."${username}".extraGroups = ["docker"];
  };
}
