{...}: {
  enable = true;
  font.name = "CaskaydiaCove Nerd Font";
  settings = {
    scrollback_lines = 10000;
    enable_audio_bell = false;
  };
  shellIntegration.enableZshIntegration = true;
  extraConfig = ''
    startup_session launch.conf
  '';
}

