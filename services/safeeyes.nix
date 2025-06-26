{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config.my) username;
  inherit
    (config.home-manager.users."${username}".wayland.windowManager)
    hyprland
    ;
  inherit (lib) makeBinPath getExe optional;
in {
  nixpkgs.overlays = [
    (_final: prev: {
      safeeyes = prev.safeeyes.overrideAttrs (_old: {
        preFixup = ''
          makeWrapperArgs+=(
            "''${gappsWrapperArgs[@]}"
            --prefix PATH : ${makeBinPath (with pkgs; [
            alsa-utils
            wlrctl
            xorg.xprop
          ])}
          )
        '';
      });
    })
  ];
  environment.systemPackages = [pkgs.safeeyes];

  # Enable for Hyprland
  home-manager.users."${username}".wayland.windowManager.hyprland.settings = {
    exec-once = optional hyprland.enable "uwsm app -- ${getExe pkgs.safeeyes}";
  };
}
