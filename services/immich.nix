{
  outputs,
  config,
  ...
}: {
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
  };

  my.cloudflared.tunnels.immich.tokenFile = config.sops.secrets."services/immich/tunnel_token".path;

  sops.secrets."services/immich/tunnel_token" = {};
}
