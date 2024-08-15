{ lib, config, pkgs, ... }: let
  cfg = config.myNixOS.libreoffice;
in {
  options.myNixOS.libreoffice.enable = lib.mkEnableOption "enable libreoffice and common office fonts";

  config = {
    fonts.packages = with pkgs; [ carlito ];
    environment.systemPackages = with pkgs; [ libreoffice ];
  };
}
