{
  pkgs,
  inputs,
  config,
  ...
}: let
  user = config.my.username;
in {
  home-manager.users.${user}.home.packages = [inputs.nixvimcfg.packages.${pkgs.system}.default];
}
