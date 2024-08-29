{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.my.stylix;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.my.stylix.heliotheme = lib.mkOption {
    default = false;
    description = ''
      If enabled, will automatically switch Stylix polarity on sunset and
      sunrise, with a 1 hour offset to stay in dark polarity longer. Currently
      uses hardcoded Australia/Sydney coordinates.
    '';
  };

  config = {
    stylix = {
      enable = true;
      image = ./assets/2024-H2.png;
      fonts = with pkgs; {
        # @TODO: these probably shouldn't all be the same with different names right?...
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

    home-manager.users."${config.my.username}" = {
      stylix.autoEnable = true;
      stylix.enable = true;
    };

    # Heliosynchronous polarity
    specialisation = lib.mkIf cfg.heliotheme {
      light.configuration.stylix = {
        polarity = lib.mkForce "light";
      };
    };


  };
}
