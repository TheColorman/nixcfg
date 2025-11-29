{config, ...}: {
  home-manager.users."${config.my.username}".programs.btop.enable = true;
}
