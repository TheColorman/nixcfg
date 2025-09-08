{
  config,
  inputs,
  lib,
  systemPlatform,
  ...
}: let
  inherit (config.my) username;

  inherit (config.home-manager.users."${username}".wayland.windowManager) hyprland;
  caelestia-pkg = inputs.caelestia-cli.packages.${systemPlatform}.with-shell;
  caelestia = lib.getExe caelestia-pkg;
in {
  environment.systemPackages = [caelestia-pkg];

  home-manager.users."${username}".wayland.windowManager.hyprland.settings = lib.mkIf hyprland.enable {
    exec-once = [
      "uwsm app -- ${caelestia} resizer -d"
      "uwsm app -- ${caelestia} shell -d"
    ];
  };
}
