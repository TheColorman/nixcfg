# My configuration for Stylix. Wallpapers are in ./assets/
# Format is <year>-H<year half (1st or 2nd)>. I change my wallpaper every 6 months.
# Artist credit:
# 2024-H1: Wallpaper Engine wallpaper (https://steamcommunity.com/sharedfiles/filedetails/?id=1288111061), by Jacket (https://steamcommunity.com/id/bloody_jacket)
# 2024-H2: Vicky Bawangun (https://vickyb18.artstation.com/)
# 2025-H1: nemupan (https://linktr.ee/nemupan). Extended using Photoshop to fit my aspect ratio
{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  scfg = config.stylix;
  asset = "2025-H1";
in {
  imports = [inputs.stylix.nixosModules.stylix];

  stylix = {
    enable = true;
    base16Scheme = (import ./assets/${asset}.nix).${scfg.polarity};
    cursor = {
      name = "Banana";
      package = pkgs.banana-cursor;
      size = 32;
    };
    image = ./assets/${asset}.png;
    fonts = with pkgs; {
      serif = {
        package = nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Propo";
      };
      sansSerif = {
        package = nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Propo";
      };
      monospace = {
        package = nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
      };
    };
    opacity = {
      applications = 0.5;
      desktop = 0.5;
      popups = 0.7;
      terminal = 0.6;
    };
    polarity = "dark";
  };

  home-manager.users."${config.my.username}" = {
    stylix.autoEnable = true;
    stylix.enable = true;
  };

  # idk man
  system.activationScripts.fix_stylix.text = ''
    rm /home/color/.gtkrc-2.0 -f
  '';

  specialisation.light.configuration.stylix.polarity = lib.mkForce "light";
}
