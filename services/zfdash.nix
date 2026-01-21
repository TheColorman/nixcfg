{
  inputs,
  config,
  ...
}: let
  domain = "zfdash.color";

  cfg = config.services.zfdash;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [inputs.zfdash-nix-flake.nixosModules.default];

  services = {
    zfdash.enable = true;

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

  my.certificates.certs."${domain}" = {};
}
