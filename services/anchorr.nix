{inputs, ...}: {
  flake.nixosModules.services-anchorr = {config, ...}: let
    evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.anchorr;
  in {
    imports = [
      inputs.anchorr.nixosModules.default
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
        JELLYFIN_NOTIFICATION_LIBRARIES = {
          "0c41907140d802bb58430fed7e2cd79e" = "";
          "f137a2dd21bbc1b99aa5c0f6bf02a805" = "";
          "4514ec850e5ad0c47b58444e17b6346c" = "";
          "34f331a89ce405e2b877d68d5ee4d4a2" = "";
        };
        USER_MAPPINGS = evalSecrets.userMappings;
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
        "services/anchorr/jwtSecret" = {};
        "services/anchorr/adminHashedPassword" = {};
        "services/anchorr/allowedRole" = {};
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
        JWT_SECRET = config.sops.placeholder."services/anchorr/jwtSecret";
        USERS = [
          {
            id = "1765715242454";
            username = "colorman";
            password = config.sops.placeholder."services/anchorr/adminHashedPassword";
            createdAt = "2025-12-14T12:27:22.454Z";
          }
        ];
        ROLE_ALLOWLIST = [
          config.sops.placeholder."services/anchorr/allowedRole"
        ];
      };
    };
  };
}
