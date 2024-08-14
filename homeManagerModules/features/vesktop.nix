{ lib, config, pkgs, ... }:
let
  cfg = config.myHomeManager.vesktop;
in
{
  options.myHomeManager.vesktop = {
    enable = lib.mkEnableOption "vesktop";
    verticalLayout = lib.mkEnableOption "only shows edge panels on hover";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ vesktop ];
    xdg.configFile."vesktop/themes/colornix.theme.css".text = with config.lib.stylix.colors; ''
      /**
      * @name colornix
      * @author Colorman
      * @version 0.0.0
      * @description Color theme for stylix
      **/


      /* >>> Floatey https://discord.com/channels/1015060230222131221/1028106818368589824/1229741268528271470 >>> */
      @import url ("https://ukrioo.github.io/cssCord/Other/TabCord.css");
      /* <<< Floatey <<< */

      /* >>> System color https://discord.com/channels/1015060230222131221/1028106818368589824/1240795855452246026 >>> */
      @import url ("https://raw.githubusercontent.com/MiniDiscordThemes/SystemColor/main/SystemColor.theme.css");
      /* <<< System color <<< */

      ${if cfg.verticalLayout then ''
        /* >>> Smol https://discord.com/channels/1015060230222131221/1028106818368589824/1234861944717049887 >>> */
        @import url("https://gist.githubusercontent.com/ayuxified/c876a58c910f013106393c20e052ba0d/raw/93c5c2edec406df64e9d218640b83e28e2370c27/smol.css");
        /* <<< Smol <<< */
      '' else ""}

      /* >>> Full height gifs https://discord.com/channels/1015060230222131221/1028106818368589824/1233977145076875275 >>> */
      [ class^="positionContainer_" ] {
        height: calc(100vh - 180px);
      }
      /* <<< Full height gifs <<< */

      /* >>> Rounded embed corners https://discord.com/channels/1015060230222131221/1028106818368589824/1242630582446461008 >>> */
      #app-mount .embedFull__14919 {
        border: 3 px solid;
        border-radius: 15px;
      }
      /* <<< Rounded embed corners */

      /* >>> Custom home icon https://discord.com/channels/1015060230222131221/1028106818368589824/1241203879941767169 */
      :root {
        --os-accent-color: #${base01} !important;
        --discord-icon: none;
        /* discord icon */
        --home-icon: block;
        /* moon icon */
        --home-icon-url: url('https://cdn.discordapp.com/emojis/1217110775601172591.gif?size=240&quality=lossless');
      }

      [ class*=childWrapper ] > svg:not ([ class*=favoriteIcon ]) {
        display: var(--discord-icon);
      }

      [class* = childWrapper]:has(svg:not([class*=favoriteIcon]))::before {
        content: ''';
        display: var(--home-icon);
        position: absolute;
        width: 70%;
        height: 70%;
        background: var(--text-normal);
        mask-image: var(--home-icon-url) center/contain no-repeat !important;
        mask: var(--home-icon-url) center/contain no-repeat !important;
      }
      /* <<< Custom home icon <<< */

      /* >>> Oneko on message bar >>> */
      [ class^="channelTextArea" ]::before {
        content: "";
        width: 32px;
        height: 32px;
        bottom: calc(100% - 3px);
        /* Mess with the - 3px to change its vertical position */
        right: 10px;
        /* Switch this from right to left to put it on the left side, or increase/decrease to change its position */
        position: absolute;
        image-rendering: pixelated;
        pointer-events: none;
        background-image: url("https://raw.githubusercontent.com/adryd325/oneko.js/14bab15a755d0e35cd4ae19c931d96d306f99f42/oneko.gif");
        animation: oneko 1s infinite;
        /* change 1s to make the animation slower/faster */
      }
      @keyframes oneko {
      /*
        if you open the background image in ur browser, you will see that it has way more frames
        so if you want, you could make ur own keyframes for a different animation
        the top left frame is 0 0, second top row is -32 0, second row second is -32 -32 and so on
        the ...00001% makes it so that there's no transition between the frames, so if you wanted say 3 frames, you'd do 0%, 33.3%; 33.30001%, 66.6%; 66.60001%, 100%
      */
        0%, 50% {
          background-position: -64px 0;
        }

        50.0001%, 100% {
          background-position: -64px -32px;
        }
      }
      /* <<< Oneko on message bar <<< */

      /* >>> Viggy loader https://discord.com/channels/1015060230222131221/1028106818368589824/1223837351831277590 >>> */
      .container__827e6 video.ready__61f2f {
        display: none;
      }
      .content_de05de::before {
        visibility: visible;
        content: ''';
        display: block;
        background: url(https://media.discordapp.net/stickers/1217112512374505613.png?size=240);
        background-size: contain;
        background-position: center;
        background-repeat: no-repeat;
        width: 128px;
        height: 128px;
        margin: auto;
        margin-bottom: 48px;
      }
      /* <<< Viggy loader <<< */
    '';
  };
}
