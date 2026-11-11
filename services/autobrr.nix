{
  flake.nixosModules.services-autobrr =
    { config, ... }:
    let
      domain = "autobrr.color";

      cfg = config.services.autobrr;
      crtCfg = config.my.certificates.certs."${domain}";
    in
    {
      services = {
        autobrr.enable = true;

        nginx.virtualHosts."${domain}" = {
          locations."/".proxyPass = "http://127.0.0.1:${toString cfg.settings.port}";
          forceSSL = true;

          sslCertificateKey = crtCfg.key.path;
          sslCertificate = crtCfg.crt.path;
        };
      };

      my.certificates.certs."${domain}" = { };
    };
}
