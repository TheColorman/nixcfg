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
      # Not sure why I need to do this, should be set to false automatically
      # based on the host
      useSSL = false;
      # Database has no password as I use socket connection, but this option
      # still needs to be set
      passwordFile = "/dev/null";
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
