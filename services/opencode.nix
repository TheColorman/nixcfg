{ self, ... }: {
  flake.nixosModules.services-opencode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      domain = "vibe.color";
      crtCfg = config.my.certificates.certs.${domain};
      user = "opencode";
      stateDir = "/var/lib/opencode";
    in
    {
      imports = [ self.nixosModules.apps-opencode ];

      services.nginx.virtualHosts.${domain} = {
        locations."/".proxyPass = "http://127.0.0.1:4096";
        forceSSL = true;

        sslCertificateKey = crtCfg.key.path;
        sslCertificate = crtCfg.crt.path;
      };

      my.certificates.certs.${domain} = { };

      users = {
        users.${user} = {
          isSystemUser = true;
          group = user;
          home = stateDir;
          # Allows untrusted access to the Nix daemon; this is not a trusted-user grant.
          extraGroups = [ "nix-users" ];
        };
        groups.${user} = { };
      };

      systemd.services.opencode = {
        description = "OpenCode headless server";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = with pkgs; [
          config.nix.package
          opencode
          git
          jujutsu
          bashInteractive
          coreutils
          findutils
          gnugrep
          gnused
          gawk
          ripgrep
          fd
          jq
          curl
          wget
          nixfmt
          nil
        ];

        serviceConfig = {
          Type = "simple";
          User = user;
          Group = user;
          WorkingDirectory = stateDir;
          StateDirectory = "opencode";
          StateDirectoryMode = "0700";
          LoadCredential = "server-password:${config.sops.secrets."services/opencode/password".path}";
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          ExecStart = pkgs.writeShellScript "opencode-serve" ''
            export OPENCODE_SERVER_PASSWORD="$(<"$CREDENTIALS_DIRECTORY/server-password")"
            exec ${lib.getExe pkgs.opencode} serve --hostname 127.0.0.1 --port 4096
          '';
        };
      };

      sops.secrets."services/opencode/password" = { };
    };
}
