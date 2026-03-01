{
  flake.nixosModules.services-jellyfin = {
    config,
    pkgs,
    ...
  }: let
    domain = "jellyfin.color";

    crtCfg = config.my.certificates.certs."${domain}";
  in {
    services = {
      # https://jellyfin.org/docs/general/post-install/networking/
      # Port  Protocol  Configurable  Description
      # 8096  TCP        ✔️           Default HTTP
      # 8920  TCP        ✔️           Default HTTPS
      # 7359  UDP        ❌           Client Discovery
      jellyfin = {
        enable = true;
        # TODO: remove once stable has 10.11.4
        package = let
          pkgs-unstable = import (fetchTarball {
            url = "https://github.com/nixos/nixpkgs/archive/addf7cf5f383a3101ecfba091b98d0a1263dc9b8.tar.gz";
            sha256 = "sha256:1zv083l3n5n4s7x2hcqki29s5gyspn7f1y6xyl6avmd94sxv9kc4";
          }) {inherit (pkgs.stdenv.hostPlatform) system;};
        in
          pkgs-unstable.jellyfin;
      };

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
  };
}
