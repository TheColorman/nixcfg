{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.myNixOS.stylix;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.myNixOS.stylix.enable = lib.mkEnableOption "Enable Stylix";

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      image = ./assets/2024-H2.png;
      fonts = with pkgs; {
        serif = {
          package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
          name = "CaskaydiaCove Nerd Font Propo";
        };
        sansSerif = {
          package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
          name = "CaskaydiaCove Nerd Font Propo";
        };
        monospace = {
          package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
          name = "CaskaydiaCove Nerd Font";
        };
      };
      polarity = "dark";
    };
    system.activationScripts.fix_stylix.text = ''
      rm /home/color/.gtkrc-2.0 -f
    '';
  };
}
