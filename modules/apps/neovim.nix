{
  pkgs,
  inputs,
  config,
  ...
}: let
  user = config.my.username;
  nvim = inputs.nvfcfg.packages.${pkgs.system}.default;
in {
  home-manager.users.${user} = {
    home.packages = [nvim];
    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
  };
}
