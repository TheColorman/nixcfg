{
  inputs,
  outputs,
  pkgs,
  config,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.nextcloud;
in {
  imports = [outputs.modules.services-cloudflared];

  services = {
    nextcloud = {
      enable = true;
      # Pinned
      package = pkgs.nextcloud31;
      webfinger = true;
      maxUploadSize = "16G";
      https = true;
      hostName = evalSecrets.hostname;
      extraApps = {
        inherit
          (pkgs.nextcloud31Packages.apps)
          app_api
          end_to_end_encryption
          notify_push
          ;
      };
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."services/nextcloud/adminpass".path;
      };
      caching.redis = true;

      database.createLocally = true;

      secretFile = config.sops.templates."nextcloud.settings.json".path;
    };
  };

  my.cloudflared.tunnels.nextcloud.tokenFile = config.sops.secrets."services/nextcloud/tunnel_token".path;

  # Sops key setup
  sops = {
    secrets = {
      "services/nextcloud/adminpass" = {};
      "services/nextcloud/tunnel_token" = {};
      "services/nextcloud/instanceid" = {};
      "services/nextcloud/passwordsalt" = {};
      "services/nextcloud/secret" = {};
    };
    templates."nextcloud.settings.json".content = let
      instanceid = config.sops.placeholder."services/nextcloud/instanceid";
      passwordsalt = config.sops.placeholder."services/nextcloud/passwordsalt";
      secret = config.sops.placeholder."services/nextcloud/secret";
    in
      builtins.toJSON {
        inherit instanceid passwordsalt secret;
      };
  };
}
