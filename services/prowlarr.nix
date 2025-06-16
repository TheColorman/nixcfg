{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  services.prowlarr = {
    enable = true;
    environmentFiles = [config.sops.templates."prowlarr.env".path];
  };

  sops = {
    secrets."services/prowlarr/apiKey".restartUnits = ["prowlarr.service"];

    templates."prowlarr.env" = {
      content = ''
        PROWLARR__AUTH__APIKEY=${config.sops.placeholder."services/prowlarr/apiKey"}
      '';
      restartUnits = ["prowlarr.service"];
    };
  };
}
