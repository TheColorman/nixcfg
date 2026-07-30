{ inputs, self, ... }:
{
  flake.nixosModules.services-authentik =
    { config, pkgs, ... }:
    let
      evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.authentik;
    in
    {
      imports = [
        inputs.authentik-nix.nixosModules.default
      ];

      services.authentik = {
        enable = true;

        settings = {
          listen = {
            http = [ "127.0.0.1:8080" ];
            trusted_proxy_cidrs = [ "127.0.0.0/8" ];
          };
          email = {
            from = "no-reply@${evalSecrets.emailDomain}";
            template_dir = self.packages.${pkgs.stdenv.hostPlatform.system}.authentik_templates;
          };
        };

        environmentFile = config.sops.templates."authentik.env".path;
      };

      my.cloudflared.tunnels.authentik.tokenFile =
        config.sops.secrets."services/authentik/tunnelToken".path;

      sops = {
        secrets = {
          "services/authentik/tunnelToken" = { };
          "services/authentik/secretKey" = { };
        };

        templates."authentik.env".content = ''
          AUTHENTIK_SECRET_KEY=${config.sops.placeholder."services/authentik/secretKey"}
        '';
      };
    };
}
