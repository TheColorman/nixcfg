{
  config,
  systemName,
  pkgs,
  ...
}: let
  cfg = config.services.firefox-syncserver;
in {
  services = {
    mysql.package = pkgs.mariadb;
    firefox-syncserver = {
      enable = true;
      singleNode = {
        enable = true;
        hostname = systemName;
        capacity = 1;
      };
      settings.port = 15468;
      secrets = config.sops.templates."firefox-syncserver.secrets.env".path;
    };
  };
  networking.firewall.allowedTCPPorts = [cfg.settings.port];

  sops = let
    master = "services/firefox-syncserver/master_secret";
    hash = "services/firefox-syncserver/hash_secret";
  in {
    secrets = {
      "${master}" = {};
      "${hash}" = {};
    };
    templates."firefox-syncserver.secrets.env".content = ''
      SYNC_MASTER_SECRET=${config.sops.placeholder."${master}"}
      SYNC_TOKENSERVER__FXA_METRICS_HASH_SECRET=${config.sops.placeholder."${hash}"}
    '';
  };
}
