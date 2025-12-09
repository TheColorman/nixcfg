{
  outputs,
  config,
  ...
}: let
  domain = "prowlarr.color";

  cfg = config.services.prowlarr;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-sops
  ];
  services = {
    prowlarr = {
      enable = true;
      environmentFiles = [config.sops.templates."prowlarr.env".path];
    };

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.settings.server.port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my.certificates.certs."${domain}" = {};

  sops = {
    secrets."services/prowlarr/apiKey".restartUnits = ["prowlarr.service"];

    templates."prowlarr.env" = {
      content = ''
        PROWLARR__AUTH__APIKEY=${config.sops.placeholder."services/prowlarr/apiKey"}
      '';
      restartUnits = ["prowlarr.service"];
    };
  };
}
