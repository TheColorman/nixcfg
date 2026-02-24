{config, ...}: let
  inherit (config.my) username;
in {
  programs.evince.enable = true;
  xdg.mime = {
    enable = true;
    defaultApplications."application/pdf" = "org.gnome.Evince.desktop";
  };

  home-manager.users."${username}".xdg.mimeApps.defaultApplications."application/pdf" = "org.gnome.Evince.desktop";
}
