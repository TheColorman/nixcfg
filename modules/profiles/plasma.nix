{ pkgs, outputs, ... }:
{
  imports = [ outputs.modules.profiles-xserver ];

  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.systemPackages = with pkgs; [ kdePackages.kwallet-pam ];

  # basic graphic
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
