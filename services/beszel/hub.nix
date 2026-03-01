{
  flake.nixosModules.services-beszel-hub = {
    config,
    pkgs,
    ...
  }: let
    domain = "beszel.color";

    cfg = config.services.beszel.hub;
    crtCfg = config.my.certificates.certs."${domain}";
  in {
    services = {
      beszel.hub = {
        enable = true;
        environment = {
          APP_URL = "https://${domain}";
        };

        # TODO: remove once stable has 0.16.1
        package = let
          pkgs-unstable =
            import (fetchTarball {
              url = "https://github.com/nixos/nixpkgs/archive/addf7cf5f383a3101ecfba091b98d0a1263dc9b8.tar.gz";
              sha256 = "sha256:1zv083l3n5n4s7x2hcqki29s5gyspn7f1y6xyl6avmd94sxv9kc4";
            }) {
              inherit (pkgs.stdenv.hostPlatform) system;
            };
        in
          pkgs-unstable.beszel;
      };

      nginx.virtualHosts."${domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
        forceSSL = true;

        sslCertificateKey = crtCfg.key.path;
        sslCertificate = crtCfg.crt.path;
      };
    };

    virtualisation.podman.dockerSocket.enable = true;

    my.certificates.certs."${domain}" = {};
  };
}
