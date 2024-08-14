{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.openfortivpn;
in
{
  imports = [ ];

  options.myNixOS.openfortivpn.enable = lib.mkEnableOption "Enable OpenFortiVPN";

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        openfortivpn
        pinentry-qt
      ];
      etc."openfortivpn/config".text = ''
        host = sslvpn.itu.dk
        port = 443
        username = alct
        pinentry = pinentry-qt
        realm = MFA
      '';
    };
  };
}
