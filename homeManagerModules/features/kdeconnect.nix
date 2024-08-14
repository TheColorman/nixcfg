{ lib, config, ... }:
let
  cfg = config.myHomeManager.kdeconnect;
in
{
  imports = [ ];

  options.myHomeManager.kdeconnect.enable = lib.mkEnableOption "Enable KDE Connect";

  config = lib.mkIf cfg.enable {
    services.kdeconnect.enable = true;
  };
}
