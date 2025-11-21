{
  inputs,
  outputs,
  config,
  systemPlatform,
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
  services.jellyfin = {
    enable = true;
    # FIXME: (2025-12) Switch away from unstable when stable gets V10.11
    package = inputs.nixpkgs-unstable.legacyPackages.${systemPlatform}.jellyfin;
  };

  my.cloudflared.tunnels.jellyfin.tokenFile = config.sops.secrets."services/jellyfin/tunnel_token".path;

  sops.secrets."services/jellyfin/tunnel_token" = {};
}
