{config, ...}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".home.pointerCursor = {
    enable = true;
    hyprcursor.enable = true;
  };
}
