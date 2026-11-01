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
        image = "docker.io/mauriceboe/trek:5.1.0@sha256:23bf3fa6a134dc38a3b4f40ef8f7e8040abc96965105dffdcfcf5f202fb5d0b7";
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
        ports = [ "127.0.0.1:${port}:${port}" ];
        environment = {
          NODE_ENV = "production";
          PORT = port;
          APP_URL = "https://${domain}";
          OIDC_ISSUER = "https://${authentikDomain}";
          OIDC_DISPLAY_NAME = "Authentik";
          OIDC_ONLY = "true";
          OIDC_ADMIN_VALUE = "Admins";
          OIDC_DISCOVERY_URL = "https://${authentikDomain}/application/o/trek/";
          FORCE_HTTPS = "true";
          ALLOWED_ORIGINS = "https://${domain}";
        };
        volumes = [
          "/var/lib/trek/data:/app/data"
          "/var/lib/trek/uploads:/app/uploads"
        ];
        environmentFiles = [
          config.sops.templates."trek.env".path
        ];
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/trek 0750 root root -"
        # 1000 is node user in container
        "d /var/lib/trek/data 0750 1000 1000 -"
        "d /var/lib/trek/uploads 0750 1000 1000 -"
      ];

      my.cloudflared.tunnels.trek.tokenFile = config.sops.secrets."services/trek/tunnelToken".path;

      sops = {
        secrets = {
          "services/trek/tunnelToken" = { };
          "services/trek/encryptionKey" = { };
          "services/trek/oidcClientId" = { };
          "services/trek/oidcClientSecret" = { };
        };

        templates."trek.env".content = ''
          ENCRYPTION_KEY=${config.sops.placeholder."services/trek/encryptionKey"}
          OIDC_CLIENT_ID=${config.sops.placeholder."services/trek/oidcClientId"}
          OIDC_CLIENT_SECRET=${config.sops.placeholder."services/trek/oidcClientSecret"}
        '';
      };
    };
}
