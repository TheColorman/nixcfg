{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.lists) imap0 foldl';
  inherit (lib.strings) removePrefix;
  inherit (builtins) toString;

  configFiles = [
    ./config
    ./profile
    ./conf/clipboard.conf
    ./conf/keyboard.conf
    ./conf/mozc.conf
    ./conf/notifications.conf
  ];
  paths = imap0 (_: v:
    removePrefix (toString ./. + "/") (toString v))
  configFiles;
  mappedFiles =
    foldl'
    (acc: x:
      acc
      // {
        "fcitx5/${x}" = {
          source = ./. + "/${x}";
          force = true;
        };
      }) {}
    paths;
in {
  home-manager.users."${config.my.username}".xdg.configFile = mappedFiles;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [fcitx5-mozc];
      waylandFrontend = true;
      plasma6Support = true;
    };
  };
}
