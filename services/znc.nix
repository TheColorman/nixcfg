{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit ((import "${inputs.nix-secrets}/evaluation-secrets.nix").services.znc) networks;

  domain = "znc.color";
  port = 6501;

  cfg = config.services.znc;
  crtCfg = config.my.certificates.certs."${domain}";
in {
  services = {
    znc = {
      enable = true;

      useLegacyConfig = false;
      mutable = false;

      modulePackages = with pkgs.zncModules; [
        clientbuffer
      ];

      config = {
        MaxBufferSize = 1000;

        Listener.listener0 = {
          AllowIRC = true;
          AllowWeb = true;
          Host = "127.0.0.1";
          IPv4 = true;
          IPv6 = false;
          Port = port;
          SSL = false;
          URIPrefix = "/";
        };

        User.admin = {
          Admin = true;
          QuitMsg = "👋";

          Network = networks;

          Pass.password = {
            Method = "SHA256";
            Hash = "5525442d7df76848c06399dddfa4cb094e984fd6edfd996b760f869f2d051551";
            Salt = "AZ)dhl6rlq,N1:wm)SB6";
          };
        };
      };
    };

    nginx.virtualHosts."${domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:${toString cfg.config.Listener.listener0.Port}";
      forceSSL = true;

      sslCertificateKey = crtCfg.key.path;
      sslCertificate = crtCfg.crt.path;
    };
  };

  my.certificates.certs."${domain}" = {};
}
