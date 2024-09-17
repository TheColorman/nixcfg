{ lib, config, ... }:
let
  tmuxEnabled = config.home-manager.users."${config.my.username}".programs.tmux.enable;
  zshEnabled = config.home-manager.users."${config.my.username}".programs.zsh.enable;
in
{
  home-manager.users."${config.my.username}" = {
    programs.kitty = {
      enable = true;
      # font.name = "CaskaydiaCove Nerd Font"; # Now managed by stylix
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        confirm_os_window_close = 0;
      };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
      };
      shellIntegration.enableZshIntegration = zshEnabled;
      extraConfig = lib.mkIf tmuxEnabled ''
        startup_session launch.conf
      '';
    };

    xdg.configFile = lib.mkIf tmuxEnabled {
      "kitty/launch.conf".text = ''
        launch sh -c "tmux new -t main" -2
      '';
    };
  };
}
