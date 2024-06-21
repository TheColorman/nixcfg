{...}: {
  enable = true;
  # font.name = "CascadiaCode";
  settings = {
    scrollback_lines = 10000;
    enable_audio_bell = false;
  };
  shellIntegration.enableZshIntegration = true;
  extraConfig = ''
    startup_session launch.conf
  '';
}

