{
  flake.nixosModules.services-home-assistant =
    { config, pkgs, ... }:
    let
      domain = "home-assistant.color";

      crtCfg = config.my.certificates.certs."${domain}";
    in
    {
      services = {
        home-assistant = {
          enable = true;
          extraComponents = [
            "default_config"
            "met"
            "tesla_wall_connector"
            "usb"
            "bluetooth"
          ];

          customComponents =
            let
              pythonPkg = config.services.home-assistant.package.python3Packages;
            in
            [
              (pythonPkg.callPackage ./_components/ha-electricity-costs-dkk { })
            ];
          customLovelaceModules = [ (pkgs.callPackage ./_lovelace/ha-price-timeline-card { }) ];
          extraPackages =
            p3p: with p3p; [
              electrickiwi-api
              (p3p.callPackage ./_components/ha-electricity-costs-dkk/electricity-cost-dkk.nix { })
            ];
        };

        nginx.virtualHosts."${domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:8123";
            proxyWebsockets = true;
          };
          extraConfig = ''
            proxy_buffering off;
          '';
          forceSSL = true;

          sslCertificateKey = crtCfg.key.path;
          sslCertificate = crtCfg.crt.path;
        };
      };

      my.certificates.certs."${domain}" = { };
    };
}
