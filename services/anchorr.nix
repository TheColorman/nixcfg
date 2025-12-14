{
  systemPlatform,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.nur.modules.nixos.default
    inputs.nur.legacyPackages.${systemPlatform}.repos.colorman.modules.anchorr
  ];

  services.anchorr."main" = {
    enable = true;
    settings = {
      JELLYSEERR_URL = "https://jellyseerr.color";
      JELLYFIN_BASE_URL = "https://jellyfin.color";
      JELLYFIN_NOTIFY_MOVIES = "true";
      JELLYFIN_NOTIFY_SERIES = "true";
      JELLYFIN_NOTIFY_SEASONS = "false";
      JELLYFIN_NOTIFY_EPISODES = "false";
      WEBHOOK_DEBOUNCE_MS = "15000";
      WEBHOOK_PORT = "8282";
      AUTO_START_BOT = "true";
      NOTIFY_ON_AVAILABLE = "false";
    };
    settingsFile = config.sops.templates."anchorr.config.json".path;
  };

  networking.firewall.allowedTCPPorts = [8282];

  sops = {
    secrets = {
      "services/anchorr/botToken" = {};
      "services/anchorr/botId" = {};
      "services/anchorr/guildId" = {};
      "services/jellyseerr/apiKey" = {};
      "services/anchorr/tmdbApiKey" = {};
      "services/anchorr/omdbApiKey" = {};
      "services/anchorr/jellyfinApiKey" = {};
      "services/jellyfin/serverId" = {};
      "services/anchorr/jellyfinChannelId" = {};
    };

    templates."anchorr.config.json".content = builtins.toJSON {
      DISCORD_TOKEN = config.sops.placeholder."services/anchorr/botToken";
      BOT_ID = config.sops.placeholder."services/anchorr/botId";
      GUILD_ID = config.sops.placeholder."services/anchorr/guildId";
      JELLYSEERR_API_KEY = config.sops.placeholder."services/jellyseerr/apiKey";
      TMDB_API_KEY = config.sops.placeholder."services/anchorr/tmdbApiKey";
      OMDB_API_KEY = config.sops.placeholder."services/anchorr/omdbApiKey";
      JELLYFIN_API_KEY = config.sops.placeholder."services/anchorr/jellyfinApiKey";
      JELLYFIN_SERVER_ID = config.sops.placeholder."services/jellyfin/serverId";
      JELLYFIN_CHANNEL_ID = config.sops.placeholder."services/anchorr/jellyfinChannelId";
    };
  };
}
