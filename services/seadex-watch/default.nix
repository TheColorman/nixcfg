{
  flake.nixosModules.services-seadex-watch =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      user = "seadex-watch";
      stateDir = "/var/lib/seadex-watch";
    in
    {
      users = {
        users.${user} = {
          isSystemUser = true;
          group = user;
          home = stateDir;
          createHome = true;
        };

        groups.${user} = { };
      };

      systemd.services.seadex-watch = {
        description = "SeaDex best-release watcher";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";

          User = user;
          Group = user;

          WorkingDirectory = stateDir;

          ExecStart =
            let
              python = pkgs.python314.withPackages (p: [ p.pyyaml ]);
            in
            pkgs.writeShellScript "seadex-watch" ''
              export SEADEX_DISCORD_WEBHOOK="$(cat "$CREDENTIALS_DIRECTORY/discord-webhook")"
              ${lib.getExe python} ${./seadex-watch.py}
            '';

          Environment = [
            "SEADEX_CONFIG=${stateDir}/config.yaml"
          ];

          LoadCredential = [
            "discord-webhook:${config.sops.secrets."services/seadexarr/discordWebhook".path}"
          ];

          StateDirectory = "seadex-watch";

          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateDevices = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
        };
      };

      systemd.timers.seadex-watch = {
        description = "Run SeaDex best-release watcher daily";

        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };
      sops.secrets."services/seadexarr/discordWebhook" = { };
    };
}
