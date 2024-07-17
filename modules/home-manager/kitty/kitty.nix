{...}: {
  enable = true;
  # font.name = "CaskaydiaCove Nerd Font";
  settings = {
    scrollback_lines = 10000;
    enable_audio_bell = false;
    confirm_os_window_close = 0;
  };
  keybindings = {
    "ctrl+c" = "copy_or_interrupt";
    "ctrl+v" = "past";
    
  };
  shellIntegration.enableZshIntegration = true;
  extraConfig = ''
    startup_session launch.conf
  '';
}
