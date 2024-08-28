{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

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
    polarity = "dark"; # @TODO: Use Specialisations to create a light polarity version.
  };
  system.activationScripts.fix_stylix.text = ''
    rm /home/color/.gtkrc-2.0 -f
  '';

  home-manager.users."${config.my.username}" = {
    stylix.autoEnable = true;
    stylix.enable = true;
  };

}
