{
  outputs,
  config,
  ...
}: let
  domain = "jellyfin.color";

  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-cloudflared
  ];
  services = {
    # https://jellyfin.org/docs/general/post-install/networking/
    # Port  Protocol  Configurable  Description
    # 8096  TCP        ✔️           Default HTTP
    # 8920  TCP        ✔️           Default HTTPS
    # 7359  UDP        ❌           Client Discovery
    jellyfin.enable = true;

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:30013";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [30013];
    allowedUDPPorts = [30013];
  };
  my = {
    certificates.certs."${domain}" = {};
    cloudflared.tunnels.jellyfin.tokenFile = config.sops.secrets."services/jellyfin/tunnel_token".path;
  };

  sops.secrets."services/jellyfin/tunnel_token" = {};
}
