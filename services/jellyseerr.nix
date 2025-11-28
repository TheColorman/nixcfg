{
  outputs,
  config,
  ...
}: {
  imports = [outputs.modules.services-cloudflared];

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  my.cloudflared.tunnels.jellyseerr.tokenFile = config.sops.secrets."services/jellyseerr/tunnel_token".path;

  sops.secrets."services/jellyseerr/tunnel_token" = {};
}
