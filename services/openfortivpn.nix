{
  flake.nixosModules.services-openfortivpn = {pkgs, ...}: {
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
