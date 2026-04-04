{
  flake.nixosModules.services-unpackerr =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      sonarrCfg = config.services.sonarr;
      radarrCfg = config.services.radarr;
    in
    {
      systemd.services.unpackerr = {
        description = "Unpackerr";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = "unpackerr";
          Group = "unpackerr";

          LoadCredential = "unpackerr-conf:${config.sops.templates."unpackerr.conf".path}";

          Restart = "on-failure";

          ReadWritePaths = [ "/mnt/neodata/default/Vault/Torrents/.data" ];

          ExecStartPre = [
            "+${pkgs.acl}/bin/setfacl -Rm u:unpackerr:rwX /mnt/neodata/default/Vault/Torrents/.data"
            "+${pkgs.acl}/bin/setfacl -m d:u:unpackerr:rwX /mnt/neodata/default/Vault/Torrents/.data"
          ];
          ExecStart = ''
            ${lib.getExe pkgs.unpackerr} -c="''${CREDENTIALS_DIRECTORY}/unpackerr-conf"
          '';
        };
      };

      users = {
        users."unpackerr" = {
          group = "unpackerr";
          isSystemUser = true;
        };
        groups."unpackerr" = { };
      };

      sops = {
        secrets = {
          "services/sonarr/apiKey" = { };
          "services/radarr/apiKey" = { };
        };
        templates."unpackerr.conf".content =
          let
            sonarrPort = toString sonarrCfg.settings.server.port;
            sonarrKey = config.sops.placeholder."services/sonarr/apiKey";
            radarrPort = toString radarrCfg.settings.server.port;
            radarrKey = config.sops.placeholder."services/radarr/apiKey";
          in
          ''
            error_stderr = true

            [[sonarr]]
            url = "http://127.0.0.1:${sonarrPort}"
            api_key = "${sonarrKey}"
            paths = ['/mnt/neodata/default/Vault/Torrents/.data/sonarr']

            [[radarr]]
            url = "http://127.0.0.1:${radarrPort}"
            api_key = "${radarrKey}"
            paths = ['/mnt/neodata/default/Vault/Torrents/.data/radarr']
          '';

      };
    };
}
