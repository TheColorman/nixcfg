{
  outputs,
  config,
  ...
}: let
  domain = "vault.color";
  port = 8000;

  crtCfg = config.my.certificates.certs."${domain}";
in {
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

        rocketAddress = "127.0.0.1";
        rocketPort = port;
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

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my.certificates.certs."${domain}" = {};

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
