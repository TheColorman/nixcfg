{
  flake.nixosModules.services-firefox-syncserver = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.firefox-syncserver;
    port = 15468;
    systemName = config.networking.hostName;
  in {
    services = {
      mysql.package = pkgs.mariadb;
      firefox-syncserver = {
        enable = true;
        singleNode = {
          enable = true;
          hostname = "${systemName}:${builtins.toString port}";
          capacity = 1;
        };
        settings = {
          host = "0.0.0.0";
          inherit port;
          url = "http://${systemName}:${builtins.toString port}";
        };
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
  };
}
