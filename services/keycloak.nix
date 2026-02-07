{
  pkgs,
  inputs,
  config,
  ...
}: let
  evalSecrets =
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.keycloak;

  cfg = config.services.keycloak;
in {
  services = {
    keycloak = {
      enable = true;
      database = {
        type = "postgresql";
        host = "/run/postgresql";
        name = "keycloak";
        username = cfg.database.name;
      };
      plugins = with pkgs; [
        junixsocket-common.passthru.jar
        junixsocket-native-common.passthru.jar
      ];
      settings = {
        hostname = "https://${evalSecrets.domain}";
        # https://developers.cloudflare.com/fundamentals/reference/http-headers
        proxy-headers = "xforwarded";
        http-enabled = true;
        http-port = 8080;
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = [cfg.database.name];
      ensureUsers = [
        {
          name = cfg.database.username;
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
    };
  };

  my.cloudflared.tunnels.keycloak.tokenFile =
    config.sops.secrets."services/keycloak/tunnelToken".path;

  sops.secrets."services/keycloak/tunnelToken" = {};
}
