{
  flake.nixosModules.apps-apktool = {
    config,
    pkgs,
    ...
  }: {
    home-manager.users."${config.my.username}" = {
      home.packages = [pkgs.apktool];
    };
  };
}
