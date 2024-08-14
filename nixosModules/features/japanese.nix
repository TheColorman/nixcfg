{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.japanese;
in
{
  imports = [ ];

  options.myNixOS.japanese.enable = lib.mkEnableOption "Enable Japanese input method";

  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [ fcitx5-mozc ];
        waylandFrontend = true;
        plasma6Support = true;
      };
    };
  };
}
