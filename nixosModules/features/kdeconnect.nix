{ lib, config, ... }:
let
  cfg = config.myNixOS.kdeconnect;
in
{
  # Note: requires home-manager version to be enabled

  imports = [ ];

  options.myNixOS.kdeconnect.enable = lib.mkEnableOption "Enable KDE Connect";

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPortRanges = [{
        from = 1714; # KDE Connect
        to = 1764;
      }];
      allowedUDPPortRanges = [{
        from = 1714; # KDE Connect
        to = 1764;
      }];
    };
  };
}
