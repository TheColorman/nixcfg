{ inputs, ... }: {
  flake.nixosModules.services-airtrail =
    { config, ... }:
    let
      airtrailSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.airtrail;
      authentikSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.authentik;

      airtrailDomain = airtrailSecrets.domain;
      authentikDomain = authentikSecrets.domain;
      port = "3323";
    in
    {
      virtualisation.oci-containers.containers = {
        airtrail-db = {
          image = "docker.io/postgres:18.6-alpine3.24@sha256:77f585114c32fbca283dc835b0596f4e52b51b4c6662d7810b2f4084f60a1873";
          environment = {
            POSTGRES_DB = "airtrail";
            POSTGRES_USER = "airtrail";
          };
          volumes = [
            "/var/lib/airtrail/database:/var/lib/postgresql"
          ];
          environmentFiles = [
            config.sops.templates."airtrail-db.env".path
          ];
          networks = [ "airtrail" ];
        };
        airtrail = {
          image = "docker.io/johly/airtrail:v3.13.0@sha256:b49918c441cd52ffd2ef795738e58031abbcfd1e8094a4365672282bb6b805b1";
          ports = [ "127.0.0.1:${port}:3000" ];
          environment = {
            ORIGIN = "https://${airtrailDomain}";
            ADDRESS_HEADER = "X-Forwarded-For";
            UPLOAD_LOCATION = "/app/uploads";

            OAUTH_ENABLED = "true";
            OAUTH_ISSUER_URL = "https://${authentikDomain}/application/o/airtrail/";
            OAUTH_AUTO_LOGIN = "true";
            OAUTH_HIDE_PASSWORD_FORM = "true";
            OAUTH_BUTTON_TEXT = "Log in with Authentik";
          };
          volumes = [
            "/var/lib/airtrail/uploads:/app/uploads"
          ];
          environmentFiles = [
            config.sops.templates."airtrail.env".path
          ];
          networks = [ "airtrail" ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/airtrail 0750 root root -"
        "d /var/lib/airtrail/database 0750 70 70 -"
        "d /var/lib/airtrail/uploads 0750 root root -"
      ];

      my.cloudflared.tunnels.airtrail.tokenFile =
        config.sops.secrets."services/airtrail/tunnelToken".path;

      sops = {
        secrets = {
          "services/airtrail/tunnelToken" = { };
          "services/airtrail/dbPassword" = { };
          "services/airtrail/oidcClientId" = { };
          "services/airtrail/oidcClientSecret" = { };
        };
        templates = {
          "airtrail.env".content = ''
            DB_URL=postgres://airtrail:${
              config.sops.placeholder."services/airtrail/dbPassword"
            }@airtrail-db:5432/airtrail
            OAUTH_CLIENT_ID=${config.sops.placeholder."services/airtrail/oidcClientId"}
            OAUTH_CLIENT_SECRET=${config.sops.placeholder."services/airtrail/oidcClientSecret"}
          '';
          "airtrail-db.env".content = ''
            POSTGRES_PASSWORD=${config.sops.placeholder."services/airtrail/dbPassword"}
          '';
        };
      };
    };
}
