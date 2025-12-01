{
  outputs,
  config,
  systemPlatform,
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
      # TODO: 2025-12 - Switch to stable version
      package = let
        pkgs-unstable =
          import (fetchTarball {
            url = "https://github.com/nixos/nixpkgs/archive/ba7b56a3b9c41c7e518cdcc8f02910936832469b.tar.gz";
            sha256 = "sha256:0b2ly9gc5y3i77a67yz9hw23xg050bdfcka3c36w57b539jn4d6f";
          }) {
            system = systemPlatform;
          };
      in
        pkgs-unstable.prowlarr;
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
