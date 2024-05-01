{...}: {
  imports = [./dependencies/xserver.nix];

  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
}
