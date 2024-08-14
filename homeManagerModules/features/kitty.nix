{ lib, config, ... }:
let
  cfg = config.myHomeManager.kitty;
in
{
  imports = [ ];

  options.myHomeManager.kitty.enable = lib.mkEnableOption "Enable kitty terminal";
  options.myHomeManager.kitty.enableTmuxIntegration = lib.mkEnableOption "Enable tmux integration";

  config = lib.mkIf cfg.enable {
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
        "ctrl+v" = "paste";
      };
      shellIntegration.enableZshIntegration = lib.mkIf config.myHomeManager.zsh.enable true;
      extraConfig = lib.mkIf cfg.enableTmuxIntegration ''
        startup_session launch.conf
      '';
    };

    home.file = lib.mkIf cfg.enableTmuxIntegration {
      ".config/kitty/launch.conf".text = ''
        launch sh -c "tmux new -t main" -2
      '';
    };
  };
}
