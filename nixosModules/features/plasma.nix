{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.plasma;
in
{
  imports = [ ];

  options.myNixOS.plasma.enable = lib.mkEnableOption "Enable Plasma";

  config = lib.mkIf cfg.enable {
    myNixOS.xserver.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    environment.systemPackages = with pkgs; [ kdePackages.kwallet-pam ];
  };
}
