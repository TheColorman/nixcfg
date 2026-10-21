{
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
      user = config.my.username;
    in
    {
      services.nginx.virtualHosts.${domain} = {
        locations."/".proxyPass = "http://127.0.0.1:4096";
        forceSSL = true;

        sslCertificateKey = crtCfg.key.path;
        sslCertificate = crtCfg.crt.path;
      };

      my.certificates.certs.${domain} = { };

      systemd.services.opencode = {
        description = "OpenCode headless server";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig = {
          Type = "simple";
          User = user;
          WorkingDirectory = config.users.users.${user}.home;
          LoadCredential = "server-password:${config.sops.secrets."services/opencode/password".path}";
          Restart = "on-failure";
          RestartSec = 5;
          ExecStart = pkgs.writeShellScript "opencode-serve" ''
            export OPENCODE_SERVER_PASSWORD="$(<"$CREDENTIALS_DIRECTORY/server-password")"
            exec ${lib.getExe pkgs.opencode} serve --hostname 127.0.0.1 --port 4096
          '';
        };
      };

      sops.secrets."services/opencode/password" = { };
    };
}
