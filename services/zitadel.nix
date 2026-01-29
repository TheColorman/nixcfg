{
  inputs,
  config,
  outputs,
  lib,
  pkgs,
  ...
}: let
  settingsFormat = pkgs.formats.yaml {};
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
          Host = "/run/postgresql";
          Port = 5432;
          Database = "zitadel";
          User = {
            Username = "zitadel";
            SSL.Mode = "disable";
          };
          Admin = {
            Username = "zitadel";
            ExistingDatabase = "zitadel";
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

  # This is copied from the source of the zitadel nixpkgs service, with the
  # original "zitadel start-from-init" command replaced with
  # "zitadel start-from-setup", as "start-from-init" always tries to use admin
  # login to create the Postgres database and role, whereas "start-from-setup"
  # supports having the database and role already created (which is done by the
  # postgresql service).
  # NOTE: If doing this, you also need to manually run all the init SQL against
  # the database, ensuring that all schemas, tables and functions are created
  # AS the zitadel user. The commands required to run are located at
  # https://github.com/zitadel/zitadel/blob/f7277b8641af5849d77db0440f0f7c91f98db2bd/cmd/initialise/sql/README.md
  systemd.services.zitadel.script = let
    configFile = settingsFormat.generate "config.yaml" cfg.settings;
    stepsFile = settingsFormat.generate "steps.yaml" cfg.steps;

    args = lib.cli.toCommandLineShellGNU {} {
      config = cfg.extraSettingsPaths ++ [configFile];
      steps = cfg.extraStepsPaths ++ [stepsFile];
      masterkeyFile = cfg.masterKeyFile;
      inherit (cfg) tlsMode;
    };
  in
    lib.mkForce ''
      zitadel start-from-setup ${args}
    '';

  my.cloudflared.tunnels.zitadel.tokenFile =
    config.sops.secrets."services/zitadel/tunnelToken".path;

  sops.secrets = {
    "services/zitadel/encryptionKey".owner = cfg.user;
    "services/zitadel/tunnelToken" = {};
  };
}
