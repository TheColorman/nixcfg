{
  flake.nixosModules.apps-eza =
    { config, ... }:
    {
      home-manager.users."${config.my.username}".programs.eza = {
        enable = true;
        git = true;
        icons = "auto";
      };
    };
}
