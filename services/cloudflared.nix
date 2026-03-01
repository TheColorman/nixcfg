# TODO: This should be removed and replaced by nginx as
# 1. These tunnels are managed imperatively through the Cloudflare Web UI. The
#    only reason I have manually defined systemd units for cloudflared is
#    because Nix doesn't seem to support this imperative management using
#    tokens.
# 2. I don't want to use Cloudflare anymore.
{
  flake.nixosModules.services-cloudflared = {
    lib,
    config,
    ...
  }: {
    options.my.cloudflared.tunnels = lib.mkOption {
      description = "Cloudflare tunnels.";
      type = lib.types.attrsOf (
        lib.types.submodule (
          _: {
            options = {
              tokenFile = lib.mkOption {
                type = lib.types.path;
                description = ''
                  File containing the token provided by Cloudflare to run a
                  tunnel. In the web interface, this is the token in the command
                  "cloudflared tunnel run --token eyJhIjo...".
                '';
              };
            };
          }
        )
      );

      default = {};
    };

    config.systemd.services =
      lib.mapAttrs' (
        name: tunnel:
          lib.nameValuePair "cloudflared-tunnel-${name}" {
            after = ["network.target" "network-online.target"];
            wants = ["network.target" "network-online.target"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              RuntimeDirectory = "cloudflared-tunnel-${name}";
              RuntimeDirectoryMode = "0400";
              LoadCredential = [
                "tokenFile:${tunnel.tokenFile}"
              ];

              ExecStart = ''
                ${config.services.cloudflared.package}/bin/cloudflared tunnel run \
                  --token-file "/run/credentials/cloudflared-tunnel-${name}.service/tokenFile"
              '';
              Restart = "on-failure";
              DynamicUser = true;
            };
          }
      )
      config.my.cloudflared.tunnels;
  };
}
