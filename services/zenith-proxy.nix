{
  flake.nixosModules.services-zenith-proxy =
    { config, ... }:
    let
      mkZenithInstance = dir: port: environmentFile: {
        image = "ghcr.io/rfresh2/zenithproxy@sha256:3ba7c981bfc051785da83d32c394e141d6cd31cb3a938866f911fea2d8548bc5";
        ports = [ "0.0.0.0:${port}:25565" ];
        volumes = [
          "/var/lib/${dir}/:/opt/ZenithProxy/"
        ];
        environment = {
          ZENITH_MC_VERSION = "1.21.4";
          ZENITH_PLATFORM = "java";
          ZENITH_IP = "caster";
        };
        environmentFiles = [ environmentFile ];
      };
    in
    {
      virtualisation.oci-containers.containers = {
        zenith-proxy =
          mkZenithInstance "zenith-proxy" "25565"
            config.sops.templates."zenith-proxy.env".path;
        zenith-alt = mkZenithInstance "zenith-alt" "25566" config.sops.templates."zenith-alt.env".path;
      };

      networking.firewall = {
        allowedTCPPorts = [
          25565
          25566
        ];
        allowedUDPPorts = [
          25565
          25566
        ];
      };

      sops = {
        secrets = {
          "services/zenith/discordToken" = { };
          "services/zenith/discordTokenAlt" = { };
          "services/zenith/discordChannelId" = { };
          "services/zenith/discordRoleId" = { };
        };
        templates =
          let
            placeholders = config.sops.placeholder;
          in
          {
            "zenith-proxy.env".content = ''
              ZENITH_DISCORD_TOKEN=${placeholders."services/zenith/discordToken"}
              ZENITH_DISCORD_CHANNEL_ID=${placeholders."services/zenith/discordChannelId"}
              ZENITH_DISCORD_ROLE_ID=${placeholders."services/zenith/discordRoleId"}
            '';
            "zenith-alt.env".content = ''
              ZENITH_DISCORD_TOKEN=${placeholders."services/zenith/discordTokenAlt"}
              ZENITH_DISCORD_CHANNEL_ID=${placeholders."services/zenith/discordChannelId"}
              ZENITH_DISCORD_ROLE_ID=${placeholders."services/zenith/discordRoleId"}
            '';
          };

      };
    };
}
