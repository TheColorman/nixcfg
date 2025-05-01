{config, ...}: let
  inherit (config.my) username;
  isEnabled = pkg: config.home-manager.users.${username}.programs.${pkg}.enable;
  zshEnabled = isEnabled "zsh";
  tmuxEnabled = isEnabled "tmux";
in {
  home-manager.users.${username}.programs.fzf = {
    enable = true;

    enableZshIntegration = zshEnabled;
    tmux.enableShellIntegration = tmuxEnabled;
  };
}
