{
  config,
  pkgs,
  ...
}: let
  inherit (config.my) username;

  # Assume mpv module is imported
  mpv = config.home-manager.users."${username}".programs.mpv.package;
in {
  users.users."${username}".packages = [
    (pkgs.jftui.override {inherit mpv;})
  ];
}
