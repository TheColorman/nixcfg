{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets."services/autobrr/sessionSecret".path;
    settings = {
      host = "127.0.0.1";
      port = 7474;
      logLevel = "DEBUG";
      checkForUpdates = true;
    };
  };

  sops.secrets."services/autobrr/sessionSecret" = {
    reloadUnits = ["autobrr.service"];
  };
}
