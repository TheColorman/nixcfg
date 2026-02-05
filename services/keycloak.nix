{
  pkgs,
  inputs,
  config,
  lib,
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
    plugins = with pkgs.keycloak.plugins; [
      junixsocket-common
      junixsocket-native-common
    ];

    settings.hostname = evalSecrets.domain;
  };

  my.cloudflared.tunnels.keycloak.tokenFile =
    config.sops.secrets."services/keycloak/tunnelToken".path;
}
