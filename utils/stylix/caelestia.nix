{
  flake.nixosModules.utils-stylix-caelestia =
    { config, lib, ... }:
    let
      inherit (config.my) username;

      caelestiaEnabled = config.my.markers ? caelestia && config.my.markers.caelestia.enable;
    in
    {
      config = lib.mkIf caelestiaEnabled {
        home-manager.users."${username}".programs.caelestia.settings = {
          appearance.font.family = {
            mono = config.stylix.fonts.monospace.name;
            sans = config.stylix.fonts.sansSerif.name;
          };

          background.wallpaperEnabled = false;
        };
      };
    };
}
