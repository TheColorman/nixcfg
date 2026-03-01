{
  flake.nixosModules.services-sonarr = {
    config,
    pkgs,
    lib,
    ...
  }: let
    domain = "sonarr.color";

    cfg = config.services.sonarr;
    crtCfg = config.my.certificates.certs."${domain}";
  in {
    services = {
      sonarr = {
        enable = true;
        environmentFiles = [config.sops.templates."sonarr.env".path];

        package = pkgs.sonarr.overrideAttrs (_final: prev: {
          src = pkgs.applyPatches {
            inherit (prev) src;
            patches = lib.singleton (pkgs.fetchpatch {
              name = "discord-timestamp-iso-8601-culture-fix";
              url = "https://patch-diff.githubusercontent.com/raw/Sonarr/Sonarr/pull/8253.patch";
              hash = "sha256-Nns8ZDDfDu7ngxnwmjRYtY7Cn1pYrEjzyvjmUsAClwI=";
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
  };
}
