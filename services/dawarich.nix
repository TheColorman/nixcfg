{ inputs, ... }: {
  flake.nixosModules.services-dawarich =
    { config, ... }:
    let
      dawarichSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.dawarich;
      authentikSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.authentik;

      localDomain = "dawarich.color";
      domain = dawarichSecrets.domain;
      crtCfg = config.my.certificates.certs."${localDomain}";
    in
    {
      services = {
        dawarich = {
          enable = true;
          localDomain = domain;
          smtp.fromAddress = "noreply@colorman.me";
          extraEnvFiles = [
            config.sops.templates."dawarich.env".path
          ];
        };

        nginx.virtualHosts."${localDomain}" = {
          locations."/".proxyPass = "http://127.0.0.1:${toString config.services.dawarich.webPort}";
          forceSSL = true;

          sslCertificateKey = crtCfg.key.path;
          sslCertificate = crtCfg.crt.path;
        };
      };

      networking.hosts."127.0.0.1" = [ localDomain ];

      my = {
        cloudflared.tunnels.immich.tokenFile = config.sops.secrets."services/dawarich/tunnel_token".path;
        certificates.certs."${localDomain}" = { };
      };
      sops = {
        secrets = {
          "services/dawarich/tunnel_token" = { };
          "services/dawarich/oidcClientId" = { };
          "services/dawarich/oidcClientSecret" = { };
        };

        templates."dawarich.env".content = ''
          OIDC_CLIENT_ID=${config.sops.placeholder."services/dawarich/oidcClientId"}
          OIDC_CLIENT_SECRET=${config.sops.placeholder."services/dawarich/oidcClientSecret"}
          OIDC_ISSUER=https://${authentikSecrets.domain}/application/o/dawarich/
          OIDC_REDIRECT_URI=https://${domain}/users/auth/openid_connect/callback
          OIDC_PROVIDER_NAME=Authentik
          ALLOW_EMAIL_PASSWORD_LOGIN=false
        '';
      };
    };
}
