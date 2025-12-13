{
  outputs,
  config,
  pkgs,
  lib,
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

      package = pkgs.sonarr.overrideAttrs (_final: prev: {
        src = pkgs.applyPatches {
          inherit (prev) src;
          patches = lib.singleton (pkgs.fetchpatch {
            name = "discord-timestamp-iso-8601-culture-fix";
            url = "https://github.com/TheColorman/Sonarr/commit/aa85e83a8a3f8acf31426a08f3ff508d40bc3e65.patch";
            hash = "sha256-Pt0fwubSMC4n8Cf+srpfjMDGq53Pms6FC+2QbXim738=";
          });
        };
      });
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
    secrets."services/sonarr/apiKey".restartUnits = ["sonarr.service"];

    templates."sonarr.env" = {
      content = ''
        SONARR__AUTH__APIKEY=${config.sops.placeholder."services/sonarr/apiKey"}
      '';
      restartUnits = ["sonarr.service"];
    };
  };
}
