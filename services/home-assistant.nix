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
          config.http = {
            trusted_proxies = [ "127.0.0.1" ];
            use_x_forwarded_for = true;
          };
        };

        nginx.virtualHosts."${domain}" = {
          locations."/".proxyPass = "http://127.0.0.1:8123";
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
