{ config, ... }: let
  username = config.my.username;
  zshEnabled = config.home-manager.users.${username}.programs.zsh.enable;
in {
  home-manager.users.${username}.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    enableZshIntegration = zshEnabled;
  };
}