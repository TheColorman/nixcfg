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
    package = let
      pkgs-unstable =
        import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/ba7b56a3b9c41c7e518cdcc8f02910936832469b.tar.gz";
          sha256 = "sha256:0b2ly9gc5y3i77a67yz9hw23xg050bdfcka3c36w57b539jn4d6f";
        }) {
          system = systemPlatform;
        };
    in
      pkgs-unstable.prowlarr;
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
