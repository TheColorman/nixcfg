{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib) mkEnableOption;
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf;

  cfg = config.my.vesktop;
  hasStylix = config ? stylix;
  isDark = config.stylix.polarity == "dark";

  themes = "vesktop/themes";

  CustomHomeIcon = readFile ./styles/CustomHomeIcon.css;
  FullHeightGifPicker = readFile ./styles/FullHeightGifPicker.css;
  OnekoMessageBar = readFile ./styles/OnekoMessageBar.css;
  RoundedEmbedCorners = readFile ./styles/RoundedEmbedCorners.css;
  SystemTheme = readFile ./styles/SystemTheme.css;
  TabCord = readFile ./styles/TabCord.css;
  ViggyLoader = readFile ./styles/ViggyLoader.css;
in {
  options.my.vesktop = {
    smol =
      mkEnableOption
      ("Enable to collapse the channel and member list, expanding the available"
        + " chat space. WARNING: Doesn't currently do anything, as the css that"
        + " makes this possible has been lost...");
  };

  config = {
    home-manager.users."${config.my.username}" = {
      home.packages = with pkgs; [vesktop];
      xdg.configFile = mkIf hasStylix {
        "${themes}/colornix.theme.css".text = with config.lib.stylix.colors; ''
          /**
           * @name colornix
           * @author Colorman
           * @version 0.0.0
           * @description Stylix-based system theme.
           */

          ${SystemTheme}
          ${CustomHomeIcon}
          ${FullHeightGifPicker}
          ${OnekoMessageBar}
          ${RoundedEmbedCorners}
          ${ViggyLoader}
          ${TabCord}
          ${optionalString cfg.smol "/* the css file is gone :( */"}

          /*
           * See https://github.com/MiniDiscordThemes/SystemColor#customisation
           * for customisation settings.
           */
          :root {
            --systemcolor-base: #${
            if isDark
            then base00
            else base05
          };
            --systemcolor-bg-blur: 0px;
          }

          .theme-dark {
            --systemcolor-bg-image: linear-gradient(
             to right, var(--primary-700), var(--primary-800));
          }

          .theme-light {
            --systemcolor-bg-image: linear-gradient(
              to right, var(--primary-200), var(--primary-100));
          }
        '';
      };
    };
  };
}
