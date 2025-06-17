{
  inputs,
  pkgs,
  config,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.nextcloud;
in {
  services.nextcloud = {
    enable = true;
    webfinger = true;
    notify_push = {
      enable = true;
      bendDomainToLocalhost = true;
    };
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
      adminpassFile = config.sops.secrets."services/nextcloud/adminpass".path;
    };
  };

  # Sops key setup
  sops.secrets."services/nextcloud/adminpass" = {};
}
