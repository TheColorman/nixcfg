{ pkgs, config, ... }: {
  home-manager.users."${config.my.username}" = {
    xdg.configFile = {
      "fcitx5/config".source = ./config;
      "fcitx5/profile".source = ./profile;
      "fcitx5/conf/clipboard.conf".source = ./conf/clipboard.conf;
      "fcitx5/conf/keyboard.conf".source = ./conf/keyboard.conf;
      "fcitx5/conf/mozc.conf".source = ./conf/mozc.conf;
      "fcitx5/conf/notifications.conf".source = ./conf/notifications.conf;
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ fcitx5-mozc ];
      waylandFrontend = true;
      plasma6Support = true;
    };
  };
}
