{
  flake.nixosModules.apps-jadx = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.my) username;
  in {
    home-manager.users.${username} = {
      home.packages = [pkgs.jadx];
    };
  };
}
