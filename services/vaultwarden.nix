{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];
  services = {
    vaultwarden = {
      enable = true;
      environmentFile = config.sops.templates."vaultwarden.env".path;
      config = {
        signupsAllowed = false;
        databaseUrl = "postgresql://vaultwarden@%2Frun%2Fpostgresql/vaultwarden";

        rocketAddress = "0.0.0.0";
        rocketPort = 8000;
      };
      dbBackend = "postgresql";
    };

    postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = ["vaultwarden"];
    };
  };

  networking.firewall.allowedTCPPorts = [8000];

  sops = {
    secrets."services/vaultwarden/adminToken" = {};
    secrets."services/vaultwarden/domain" = {};

    templates."vaultwarden.env" = {
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."services/vaultwarden/adminToken"}
        DOMAIN=${config.sops.placeholder."services/vaultwarden/domain"}
      '';
      restartUnits = ["vaultwarden.service"];
    };
  };
}
