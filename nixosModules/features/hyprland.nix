{ lib, config, ... }:
let
  cfg = config.myNixOS.hyprland;
in
{
  imports = [ ];

  options.myNixOS.hyprland.enable = lib.mkEnableOption "Enable Hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
  };
}
