{
  inputs,
  config,
  outputs,
  lib,
  ...
}: let
  evalSecrets =
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.zitadel;

  cfg = config.services.zitadel;
in {
  imports = [
    outputs.modules.services-cloudflared
  ];

  assertions = [
    {
      assertion =
        lib.versionOlder config.services.postgresql.package.version
        "18";
      message = ''
        ZITADEL does not support versions of PostgreSQL above 17. Check for
        updates to this at
        https://zitadel.com/docs/self-hosting/manage/database
      '';
    }
  ];
  services = {
    zitadel = {
      enable = true;

      masterKeyFile = config.sops.secrets."services/zitadel/encryptionKey".path;
      settings = {
        Telemetry.Enabled = false;
        ExternalPort = 443;
        ExternalDomain = evalSecrets.domain;
        ExternalSecure = true;
        TLS.Enabled = false;
        Database.postgres = {
          Host = "localhost";
          Port = 5432;
          Database = "zitadel";
          User = {
            Username = "zitadel";
            SSL.Mode = "disable";
          };
        };
      };
    };

    postgresql = {
      enable = true;
      ensureDatabases = [cfg.settings.Database.postgres.Database];
      ensureUsers = [
        {
          name = cfg.settings.Database.postgres.User.Username;
          ensureClauses.login = true;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  my.cloudflared.tunnels.zitadel.tokenFile =
    config.sops.secrets."services/zitadel/tunnelToken".path;

  sops.secrets = {
    "services/zitadel/encryptionKey" = {};
    "services/zitadel/tunnelToken" = {};
  };
}
