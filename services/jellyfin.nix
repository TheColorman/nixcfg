{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-cloudflared
  ];

  # https://jellyfin.org/docs/general/post-install/networking/
  # Port  Protocol  Configurable  Description
  # 8096  TCP        ✔️           Default HTTP
  # 8920  TCP        ✔️           Default HTTPS
  # 7359  UDP        ❌           Client Discovery
  services.jellyfin.enable = true;

  networking.firewall = {
    allowedTCPPorts = [30013];
    allowedUDPPorts = [30013];
  };

  my.cloudflared.tunnels.jellyfin.tokenFile = config.sops.secrets."services/jellyfin/tunnel_token".path;

  sops.secrets."services/jellyfin/tunnel_token" = {};
}
