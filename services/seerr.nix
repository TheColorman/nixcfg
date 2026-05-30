{
  flake.nixosModules.services-seerr =
    { config, ... }:
    let
      domain = "jellyseerr.color";

      cfg = config.services.seerr;
      crtCfg = config.my.certificates.certs."${domain}";
    in
    {
      services = {
        seerr = {
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
        certificates.certs."${domain}" = { };
        cloudflared.tunnels.jellyseerr.tokenFile =
          config.sops.secrets."services/jellyseerr/tunnel_token".path;
      };

      sops.secrets."services/jellyseerr/tunnel_token" = { };
    };
}
