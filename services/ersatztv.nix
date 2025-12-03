{config, ...}: let
  domain = "tv.color";

  cfg = config.services.ersatztv;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  services = {
    ersatztv = {
      enable = true;
      environment.ETV_UI_PORT = "8409";
    };

    nginx.virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.environment.ETV_UI_PORT}";
        proxyWebsockets = true;
      };
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my.certificates.certs."${domain}" = {};
}
