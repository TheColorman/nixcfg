{
  lib,
  config,
  ...
}: let
  cfg = config.my.acme;
in {
  options.my.acme.certificateHosts = lib.mkOption {
    description = ''
      List of domain names to include in the 'primary' certificate requested by
      ACME.
    '';
    type = lib.types.listOf lib.types.str;
    default = [];
  };

  config = {
    services.nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedUwsgiSettings = true;
      recommendedProxySettings = true;
      recommendedBrotliSettings = true;
    };

    networking.firewall.allowedTCPPorts = [80 443];

    security.acme = {
      acceptTerms = true;

      # Create a single cert for all domains
      certs = lib.mkIf (cfg.certificateHosts != []) {
        # Name used to refer to this certificate
        "primary" = {
          email = "acme-nixos@colorman.me";
          dnsProvider = "cloudflare";
          environmentFile = config.sops.templates."acme-lego.env".path;

          # Use first domain as the main one, use rest as extraDomainNames
          domain = builtins.head cfg.certificateHosts;
          extraDomainNames = lib.lists.drop 1 cfg.certificateHosts;
        };
      };
    };

    users.users."nginx".extraGroups = ["acme" "certboy"];

    sops = {
      secrets."services/acme/cloudflareDnsApiToken" = {};

      templates."acme-lego.env".content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder."services/acme/cloudflareDnsApiToken"}
      '';
    };
  };
}
