{ inputs, ... }:
{
  flake.nixosModules.services-nextcloud =
    {
      pkgs,
      config,
      ...
    }:
    let
      nextcloudSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.nextcloud;
      authentikSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.authentik;
    in
    {
      services.nextcloud = {
        enable = true;
        # Pinned
        package = pkgs.nextcloud33;
        webfinger = true;
        maxUploadSize = "16G";
        https = true;
        hostName = nextcloudSecrets.hostname;
        extraApps = {
          inherit (pkgs.nextcloud33Packages.apps)
            end_to_end_encryption
            notify_push
            user_oidc
            ;
        };
        config = {
          dbtype = "pgsql";
          adminuser = "admin";
          adminpassFile = config.sops.secrets."services/nextcloud/adminpass".path;
        };
        settings = {
          serverid = 444;
          maintenance_window_start = 1;
          # OIDC settings
          lost_password_link = "disabled";
          user_oidc.login_label = "Log in with ColorCloud";
        };
        secrets = {
          instanceid = config.sops.secrets."services/nextcloud/instanceid".path;
          passwordsalt = config.sops.secrets."services/nextcloud/passwordsalt".path;
          secret = config.sops.secrets."services/nextcloud/secret".path;
        };

        configureRedis = true;
        caching.redis = true;

        database.createLocally = true;
      };

      my.cloudflared.tunnels.nextcloud.tokenFile =
        config.sops.secrets."services/nextcloud/tunnel_token".path;

      # Sops key setup
      sops = {
        secrets = {
          "services/nextcloud/adminpass" = { };
          "services/nextcloud/tunnel_token" = { };
          "services/nextcloud/instanceid" = { };
          "services/nextcloud/passwordsalt" = { };
          "services/nextcloud/secret" = { };
          "services/nextcloud/oidc_id" = { };
          "services/nextcloud/oidc_secret" = { };
        };
      };
    };
}
