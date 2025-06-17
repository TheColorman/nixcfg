{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.templates."vaultwarden.env".path;
    config = {
      SIGNUPS_ALLOWED = false;
    };
  };

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
