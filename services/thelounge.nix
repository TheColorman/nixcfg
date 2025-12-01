{config, ...}: let
  domain = "lounge.color";

  cfg = config.services.thelounge;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  services = {
    thelounge = {
      enable = true;
      extraConfig = {
        disableMediaPreview = true;
        leaveMessage = "👋 byebye";
      };
    };

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my.certificates.certs."${domain}" = {};
}
