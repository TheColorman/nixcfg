{
  outputs,
  config,
  ...
}: let
  domain = "radarr.color";

  cfg = config.services.radarr;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-sops
  ];
  services = {
    radarr = {
      enable = true;
      environmentFiles = [config.sops.templates."radarr.env".path];

      openFirewall = true;
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
    secrets."services/radarr/apiKey".restartUnits = ["radarr.service"];

    templates."radarr.env" = {
      content = ''
        RADARR__AUTH__APIKEY=${config.sops.placeholder."services/radarr/apiKey"}
      '';
      restartUnits = ["radarr.service"];
    };
  };
}
