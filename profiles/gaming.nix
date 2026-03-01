{
  flake.nixosModules.profiles-gaming = {
    config,
    pkgs,
    ...
  }: {
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        protontricks.enable = true;
      };
      gamemode.enable = true;
    };

    home-manager.users."${config.my.username}" = {
      programs.mangohud = {
        enable = true;
        settings.position = "top-right";
      };
      home = {
        sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        packages = with pkgs; [protonup-ng];
      };
    };

    # Allow Steam Local Network Game Transfers
    networking.firewall = {
      allowedTCPPorts = [27040];
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ];
    };
  };
}
