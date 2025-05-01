{config, ...}: let
  inherit (config.my) username;
  zshEnabled = config.home-manager.users.${username}.programs.zsh.enable;
in {
  home-manager.users.${username}.programs.zoxide = {
    enable = true;
    options = ["--cmd cd"];

    enableZshIntegration = zshEnabled;
  };
}
