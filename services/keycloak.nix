{
  pkgs,
  inputs,
  config,
  ...
}: let
  evalSecrets =
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.keycloak;
in {
  services.keycloak = {
    enable = true;
    database = {
      type = "postgresql";
      host = "/run/postgresql";
    };
    plugins = with pkgs; [
      junixsocket-common.passthru.jar
      junixsocket-native-common.passthru.jar
    ];
    settings = {
      hostname = evalSecrets.domain;
      # https://developers.cloudflare.com/fundamentals/reference/http-headers
      proxy-headers = "xforwarded";
      http-enabled = true;
    };
  };

  my.cloudflared.tunnels.keycloak.tokenFile =
    config.sops.secrets."services/keycloak/tunnelToken".path;

  sops.secrets."services/keycloak/tunnelToken" = {};
}
