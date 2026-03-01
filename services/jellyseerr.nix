{
  flake.nixosModules.services-jellyseerr = {config, ...}: let
    domain = "jellyseerr.color";

    cfg = config.services.jellyseerr;
    crtCfg = config.my.certificates.certs."${domain}";
  in {
    services = {
      jellyseerr = {
        enable = true;
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
      certificates.certs."${domain}" = {};
      cloudflared.tunnels.jellyseerr.tokenFile = config.sops.secrets."services/jellyseerr/tunnel_token".path;
    };

    sops.secrets."services/jellyseerr/tunnel_token" = {};
  };
}
