{ inputs, ... }: {
  flake.nixosModules.services-trek =
    { config, ... }:
    let
      trekSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.trek;
      authentikSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.authentik;

      inherit (trekSecrets) domain;
      authentikDomain = authentikSecrets.domain;
      port = "3322";
    in
    {
      virtualisation.oci-containers.containers.trek = {
        image = "mauriceboe/trek:4.3.3@sha256:1ef1ccf41af8ae409e0435518facb5789b6adc99681ef26d1869508355455749";
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--tmpfs=/tmp:rw,noexec,nosuid,size=128m"
        ];
        capabilities = {
          ALL = false;
          CHOWN = true;
          SETUID = true;
          SETGID = true;
        };
        ports = [ "127.0.0.1:${port}:3000" ];
        environment = {
          NODE_ENV = "production";
          PORT = port;
          APP_URL = "https://${domain}";
          OIDC_ISSUER = "https://${authentikDomain}";
          OIDC_DISPLAY_NAME = "Authentik";
          OIDC_ONLY = "true";
          OIDC_ADMIN_VALUE = "Admins";
          OIDC_DISCOVERY_URL = "https://${authentikDomain}/application/o/trek/";
        };
        volumes = [
          "/var/lib/trek/data:/app/data"
          "/var/lib/trek/uploads:/app/uploads"
        ];
        environmentFiles = [
          config.sops.templates."trek.env".path
        ];
      };

      my.cloudflared.tunnels.trek.tokenFile = config.sops.secrets."services/trek/tunnelToken".path;

      sops = {
        secrets = {
          "services/trek/tunnelToken" = { };
          "services/trek/encrytionKey" = { };
          "services/trek/oidcClientId" = { };
          "services/trek/oidcClientSecret" = { };
        };

        templates."trek.env".content = ''
          ENCRYPTION_KEY=${config.sops.placeholder."services/trek/encrytionKey"}
          OIDC_CLIENT_ID=${config.sops.placeholder."services/trek/oidcClientId"}
          OIDC_CLIENT_SECRET=${config.sops.placeholder."services/trek/oidcClientSecret"}
        '';
      };
    };
}
