{
  outputs,
  config,
  pkgs,
  lib,
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

      package = pkgs.radarr.overrideAttrs (_final: prev: {
        src = pkgs.applyPatches {
          inherit (prev) src;
          patches = lib.singleton (pkgs.fetchpatch {
            name = "discord-timestamp-iso-8601-culture-fix";
            url = "https://github.com/TheColorman/Radarr/commit/09dbc3bf95c68d46ef8fac136a6c9883569f3958.patch";
            hash = "sha256-lxXKPEHVE5QShQDHOfSHYQtswezq7v5CrWBcvhgd4c4=";
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
    secrets."services/radarr/apiKey".restartUnits = ["radarr.service"];

    templates."radarr.env" = {
      content = ''
        RADARR__AUTH__APIKEY=${config.sops.placeholder."services/radarr/apiKey"}
      '';
      restartUnits = ["radarr.service"];
    };
  };
}
