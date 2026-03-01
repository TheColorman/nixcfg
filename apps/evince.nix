{
  flake.nixosModules.apps-evince = {config, ...}: {
    programs.evince.enable = true;
    xdg.mime = {
      enable = true;
      defaultApplications."application/pdf" = "org.gnome.Evince.desktop";
    };

    home-manager.users."${config.my.username}".xdg.mimeApps.defaultApplications."application/pdf" = "org.gnome.Evince.desktop";
  };
}
