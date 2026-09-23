{
  flake.nixosModules.apps-opencode =
    { config, pkgs, ... }:
    {
      users.users."${config.my.username}".packages = [
        pkgs.opencode
      ];
    };
}
