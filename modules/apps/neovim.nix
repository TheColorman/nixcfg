{
  pkgs,
  inputs,
  config,
  ...
}: let
  user = config.my.username;
  nvim = inputs.nixvimcfg.packages.${pkgs.system}.default;
in {
  home-manager.users.${user} = {
    home.packages = [ pkgs.nixd nvim ];
    home.sessionVariables.EDITOR = "nvim";
  };
}
