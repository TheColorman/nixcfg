{
  flake.nixosModules.services-home-assistant =
    { config, ... }:
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
