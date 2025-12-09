{
  outputs,
  config,
  ...
}: let
  domain = "autobrr.color";

  cfg = config.services.autobrr;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-sops
  ];

  services = {
    autobrr = {
      enable = true;
      secretFile = config.sops.secrets."services/autobrr/sessionSecret".path;
    };

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.settings.port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my.certificates.certs."${domain}" = {};

  sops.secrets."services/autobrr/sessionSecret" = {
    reloadUnits = ["autobrr.service"];
  };
}
