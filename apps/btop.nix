{
  config,
  pkgs,
  ...
}: {
  home-manager.users."${config.my.username}".programs.btop = {
    enable = true;
    package = pkgs.btop-rocm;
  };
}
