{ config, ... }: let
  user = config.my.username;
in {
  virtualisation.docker.enable = true;

  users.users."${user}".extraGroups = [ "docker" ];
}
