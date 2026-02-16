{
  outputs,
  config,
  ...
}: let
  domain = "photos.color";

  cfg = config.services.immich;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-cloudflared
  ];

  services = {
    immich = {
      enable = true;

      host = "127.0.0.1";
      port = 2283;

      mediaLocation = "/mnt/neodata/default/immich/data";

      # Disable deprecated pgvector.rs extension
      database.enableVectors = false;

      openFirewall = true;
    };

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my = {
    cloudflared.tunnels.immich.tokenFile = config.sops.secrets."services/immich/tunnel_token".path;
    certificates.certs."${domain}" = {};
  };

  sops.secrets."services/immich/tunnel_token" = {};
}
