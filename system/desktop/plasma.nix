{self, ...}: {
  flake.nixosModules.system-desktop-plasma = {pkgs, ...}: {
    imports = [self.nixosModules.system-desktop-wayland];

    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    environment.systemPackages = with pkgs; [kdePackages.kwallet-pam];
  };
}
