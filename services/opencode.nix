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
      # Nginx is the public entry point; keep OpenCode bound to loopback.
      serveArgs = [
        "--print-logs"
        "serve"
        "--hostname"
        "127.0.0.1"
        "--port"
        "4096"
      ];
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
          shell = pkgs.bashInteractive;
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
            export OPENCODE_PASSWORD="$(<"$CREDENTIALS_DIRECTORY/server-password")"
            exec ${lib.getExe pkgs.opencode} ${lib.escapeShellArgs serveArgs}
          '';
        };
      };

      sops.secrets."services/opencode/password" = { };
    };
}
