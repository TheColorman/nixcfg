# My configuration for Stylix. Wallpapers are in ./assets/
# Format is <year>-H<year half (1st or 2nd)>. I change my wallpaper every 6 months.
# Artist credit:
# 2024-H1: Wallpaper Engine wallpaper (https://steamcommunity.com/sharedfiles/filedetails/?id=1288111061), by Jacket (https://steamcommunity.com/id/bloody_jacket)
# 2024-H2: Vicky Bawangun (https://vickyb18.artstation.com/)
# 2025-H1: nemupan (https://linktr.ee/nemupan). Extended using Photoshop to fit my aspect ratio
# 2025-H2: 夏の影 (https://pixiv.net/artworks/90877153) by あきま (https://pixiv.net/users/19301797)
# 2026-H1: Crescent #4 (https://pixiv.net/artworks/120894232) by DDal (https://pixiv.net/users/267137)
{ inputs, ... }:
{
  flake.nixosModules.utils-stylix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      asset = "2026-H1.jpg";

      inherit (config.my) username;
    in
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        # base16Scheme = (import ./assets/${asset}.nix).${scfg.polarity};
        cursor = {
          name = "Banana";
          package = pkgs.banana-cursor;
          size = 32;
        };
        image = ./_assets/${asset};
        fonts = with pkgs; {
          serif = {
            package = maple-mono.NF-unhinted;
            name = "Maple Mono NF";
          };
          sansSerif = {
            package = maple-mono.NF-unhinted;
            name = "Maple Mono NF";
          };
          monospace = {
            package = maple-mono.NF-unhinted;
            name = "Maple Mono NF";
          };
        };
        opacity = {
          applications = 0.5;
          desktop = 0.5;
          popups = 0.7;
          terminal = 0.8;
        };
        polarity = "dark";
      };

      specialisation.light.configuration.stylix.polarity = lib.mkForce "light";

      home-manager.users."${username}" = {
        stylix = {
          autoEnable = true;
          enable = true;
        };

        gtk.gtk4.theme = config.home-manager.users.${username}.gtk.theme;
      };

      # idk man
      system.activationScripts.fix_stylix.text = ''
        rm /home/color/.gtkrc-2.0 -f
      '';
    };
}
