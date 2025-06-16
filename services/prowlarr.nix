{
  inputs,
  outputs,
  config,
  systemPlatform,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  services.prowlarr = {
    enable = true;
    # TODO: 2025-12 - Switch to stable version
    package = inputs.nixpkgs-unstable.legacyPackages.${systemPlatform}.prowlarr;
    environmentFiles = [config.sops.templates."prowlarr.env".path];

    openFirewall = true;
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
