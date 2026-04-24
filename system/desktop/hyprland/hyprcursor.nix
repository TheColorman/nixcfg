{
  flake.nixosModules.system-desktop-hyprland-hyprcursor =
    { config, lib, ... }:
    let
      inherit (config.my) username;

      stylixCursor = lib.attrByPath [ "stylix" "cursor" ] null config;
    in
    {
      home-manager.users.${username}.home.pointerCursor = lib.mkIf (stylixCursor.name or null != null) {
        hyprcursor.enable = true;
      };
    };
}
