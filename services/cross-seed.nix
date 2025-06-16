{
  outputs,
  config,
  lib,
  ...
}: let
  inherit (lib.lists) optional;

  prowlarrCfg = config.services.prowlarr;
  sonarrCfg = config.services.sonarr;
  radarrCfg = config.services.radarr;
in {
  imports = [
    outputs.modules.services-sops
  ];

  services.cross-seed = {
    enable = true;
    settingsFile = config.sops.templates."cross-seed.settings.json".path;
    settings = {
      host = "0.0.0.0";
      useClientTorrents = true;
      delay = 60;
      dataDirs = [];
      linkCategory = "cross-seed-link";
      linkDirs = [
        "/mnt/neodata/default/Vault/Torrents/.data"
      ];
      linkType = "hardlink";
      flatLinking = false;
      matchMode = "partial";
      skipRecheck = true;
      autoResumeMaxDownload = 52428800; # 50 MiB
      maxDataDepth = 2;
      torrentDir = null;
      includeSingleEpisodes = false;
      includeNonVideos = false;
      seasonFromEpisodes = 1;
      fuzzySizeThreshold = 0.02;
      excludeOlder = "4 weeks";
      excludeRecentSearch = "1 week";
      action = "inject";
      duplicateCategories = false;
      rssCadence = "30 minutes";
      searchCadence = "1 day";
      snatchTimeout = "30 seconds";
      searchTimeout = "2 minutes";
      searchLimit = 400;
      blockList = [];
    };
  };

  sops = {
    secrets = {
      "services/cross-seed/apiKey" = {};
      "services/prowlarr/apiKey" = {};
      "services/sonarr/apiKey" = {};
      "services/radarr/apiKey" = {};
      "services/qbittorrentvpn/webuiUser" = {};
      "services/qbittorrentvpn/webuiPass" = {};
    };
    templates."cross-seed.settings.json".content = let
      crossSeedKey = config.sops.placeholder."services/cross-seed/apiKey";
      prowlarrPort = builtins.toString prowlarrCfg.settings.server.port;
      prowlarrKey = config.sops.placeholder."services/prowlarr/apiKey";
      sonarrPort = builtins.toString sonarrCfg.settings.server.port;
      sonarrKey = config.sops.placeholder."services/sonarr/apiKey";
      radarrPort = builtins.toString radarrCfg.settings.server.port;
      radarrKey = config.sops.placeholder."services/radarr/apiKey";
      qbitUser = config.sops.placeholder."services/qbittorrentvpn/webuiUser";
      qbitPass = config.sops.placeholder."services/qbittorrentvpn/webuiPass";
    in
      builtins.toJSON {
        apiKey = crossSeedKey;
        torznab = [
          "http://127.0.0.1:${prowlarrPort}/6/api?apikey=${prowlarrKey}"
          "http://127.0.0.1:${prowlarrPort}/12/api?apikey=${prowlarrKey}"
          "http://127.0.0.1:${prowlarrPort}/15/api?apikey=${prowlarrKey}"
          "http://127.0.0.1:${prowlarrPort}/16/api?apikey=${prowlarrKey}"
        ];
        sonarr =
          optional sonarrCfg.enable
          "http://127.0.0.1:${sonarrPort}?apikey=${sonarrKey}";
        radarr =
          optional radarrCfg.enable
          "http://127.0.0.1:${radarrPort}?apikey=${radarrKey}";
        qbittorrentUrl = "http://${qbitUser}:${qbitPass}@127.0.0.1:10095";
      };
  };
}
