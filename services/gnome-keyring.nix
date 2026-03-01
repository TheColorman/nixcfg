{
  flake.nixosModules.services-gnome-keyring = {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      hyprlock.enableGnomeKeyring = true;
    };
  };
}
