{ inputs, lib, ... }:
{
  flake.nixosModules.services-seadexarr =
    { config, pkgs, ... }:
    let
      evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.seadexarr;

      sonarrCfg = config.services.sonarr;
      radarrCfg = config.services.radarr;
    in
    {
      imports = [ inputs.seadexarr.nixosModules.default ];

      services.seadexarr."main" = {
        enable = false;
        package = pkgs.seadexarr.overrideAttrs {
          src = pkgs.fetchFromGitHub {
            owner = "TheColorman";
            repo = "seadexarr";
            rev = "d19d172f";
            hash = "sha256-l6L51Pt8AKU+VblrXpwuNiqc0QW41qz1WKMVMYF6d+0=";
          };
        };
        settings =
          let
            sonarrPort = toString sonarrCfg.settings.server.port;
            radarrPort = toString radarrCfg.settings.server.port;
          in
          {
            sonarr_url = "http://127.0.0.1:${sonarrPort}";
            ignore_movies_in_radarr = true;
            radarr_url = "http://127.0.0.1:${radarrPort}";

            sonarr_torrent_category = "sonarr";
            radarr_torrent_category = "radarr";
            torrent_tags = [ "seadex" ];

            inherit (evalSecrets) trackers;

            nyaa_host = "nyaa.iss.ink";
          };
        settingsFile = config.sops.templates."seadexarr.config.yaml".path;

        scheduleTime = 24; # Run every 24 hours
      };

      networking.firewall.allowedTCPPorts = [ 8282 ];

      sops = {
        secrets = {
          "services/sonarr/apiKey" = { };
          "services/radarr/apiKey" = { };
          "services/qbittorrentvpn/webuiUser" = { };
          "services/qbittorrentvpn/webuiPass" = { };
          "services/seadexarr/discordWebhook" = { };
        };

        templates."seadexarr.config.yaml".content = lib.generators.toYAML { } {
          sonarr_api_key = config.sops.placeholder."services/sonarr/apiKey";
          radarr_api_key = config.sops.placeholder."services/radarr/apiKey";

          qbit_info = {
            host = "http://127.0.0.1:10095";
            username = config.sops.placeholder."services/qbittorrentvpn/webuiUser";
            password = config.sops.placeholder."services/qbittorrentvpn/webuiPass";
          };

          discord_url = config.sops.placeholder."services/seadexarr/discordWebhook";
        };
      };
    };
}
