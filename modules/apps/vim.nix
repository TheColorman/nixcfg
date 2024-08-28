{ config, pkgs, ... }: {
  home-manager.users."${config.my.username}" = {
    home = {
      packages = [ pkgs.vim ];
      sessionVariables.EDITOR = "vim";
    };
  };
}
