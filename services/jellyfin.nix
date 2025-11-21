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
    package = let
      pkgs-unstable =
        import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/ba7b56a3b9c41c7e518cdcc8f02910936832469b.tar.gz";
          sha256 = "sha256:0b2ly9gc5y3i77a67yz9hw23xg050bdfcka3c36w57b539jn4d6f";
        }) {
          system = systemPlatform;
        };
    in
      pkgs-unstable.jellyfin;
  };

  my.cloudflared.tunnels.jellyfin.tokenFile = config.sops.secrets."services/jellyfin/tunnel_token".path;

  sops.secrets."services/jellyfin/tunnel_token" = {};
}
