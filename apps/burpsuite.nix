{
  flake.nixosModules.apps-burpsuite = {
    config,
    pkgs,
    ...
  }: {
    nixpkgs.config.allowUnfree = true;

    home-manager.users."${config.my.username}".home.packages = [pkgs.burpsuite];
  };
}
