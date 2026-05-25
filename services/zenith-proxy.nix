{
  flake.nixosModules.services-zenith-proxy =
    { config, ... }:
    {
      virtualisation.oci-containers.containers.zenith-proxy = {
        image = "ghcr.io/rfresh2/zenithproxy@sha256:045294f15a2253816f3a8bb1f43abf41d6148ae62cd2fe83eb13a5d3c8bf508d";
        ports = [ "0.0.0.0:25565:25565" ];
        volumes = [
          "/var/lib/zenith-proxy/:/opt/ZenithProxy/"
        ];
        environment = {
          ZENITH_MC_VERSION = "1.21.4";
          ZENITH_PLATFORM = "java";
          ZENITH_IP = "caster";
        };
        environmentFiles = [ config.sops.templates."zenith-proxy.env".path ];
      };

      networking.firewall = {
        allowedTCPPorts = [ 25565 ];
        allowedUDPPorts = [ 25565 ];
      };

      sops = {
        secrets = {
          "services/zenith/discordToken" = { };
          "services/zenith/discordChannelId" = { };
          "services/zenith/discordRoleId" = { };
        };

        templates."zenith-proxy.env".content =
          let
            placeholders = config.sops.placeholder;
          in
          ''
            ZENITH_DISCORD_TOKEN=${placeholders."services/zenith/discordToken"}
            ZENITH_DISCORD_CHANNEL_ID=${placeholders."services/zenith/discordChannelId"}
            ZENITH_DISCORD_ROLE_ID=${placeholders."services/zenith/discordRoleId"}
          '';

      };
    };
}
