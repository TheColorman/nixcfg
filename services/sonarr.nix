{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  services.sonarr = {
    enable = true;
    environmentFiles = [config.sops.templates."sonarr.env".path];

    openFirewall = true;
  };

  sops = {
    secrets."services/sonarr/apiKey".restartUnits = ["sonarr.service"];

    templates."sonarr.env" = {
      content = ''
        SONARR__AUTH__APIKEY=${config.sops.placeholder."services/sonarr/apiKey"}
      '';
      restartUnits = ["sonarr.service"];
    };
  };
}
