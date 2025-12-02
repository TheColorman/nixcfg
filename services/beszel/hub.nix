{config, ...}: let
  domain = "beszel.color";

  cfg = config.services.beszel.hub;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  services = {
    beszel.hub = {
      enable = true;
      environment = {
        APP_URL = "https://${domain}";
      };
    };

    nginx.virtualHosts."${domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  virtualisation.podman.dockerSocket.enable = true;

  my.certificates.certs."${domain}" = {};
}
