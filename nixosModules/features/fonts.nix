{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.fonts;
  nerdfont = with pkgs; (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
in
{
  imports = [ ];

  options.myNixOS.fonts.enable = lib.mkEnableOption "Enable fonts";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nerdfont ];
    fonts.packages = with pkgs; [ nerdfont ];
  };
}
