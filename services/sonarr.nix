{
  outputs,
  config,
  ...
}: let
  domain = "sonarr.color";

  cfg = config.services.sonarr;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-sops
  ];
  services = {
    sonarr = {
      enable = true;
      environmentFiles = [config.sops.templates."sonarr.env".path];

      openFirewall = true;
    };

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.settings.server.port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  users.users."nginx".extraGroups = ["certboy"];

  my.certificates.certs."${domain}" = {};

  sops = {
    secrets."services/sonarr/apiKey".restartUnits = ["sonarr.service"];

    templates."sonarr.env" = {
      content = ''
        SONARR__AUTH__APIKEY=${config.sops.placeholder."services/sonarr/apiKey"}
      '';
      restartUnits = ["sonarr.service"];
    };
  };
}
