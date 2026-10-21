{
  flake.nixosModules.services-opencode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = config.my.username;
    in
    {
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
            exec ${lib.getExe pkgs.opencode} serve --hostname 0.0.0.0 --port 4096
          '';
        };
      };

      sops.secrets."services/opencode/password" = { };
    };
}
