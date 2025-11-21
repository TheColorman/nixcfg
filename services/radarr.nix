{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  services.radarr = {
    enable = true;
    environmentFiles = [config.sops.templates."radarr.env".path];

    openFirewall = true;
  };

  sops = {
    secrets."services/radarr/apiKey".restartUnits = ["radarr.service"];

    templates."radarr.env" = {
      content = ''
        RADARR__AUTH__APIKEY=${config.sops.placeholder."services/radarr/apiKey"}
      '';
      restartUnits = ["radarr.service"];
    };
  };
}
