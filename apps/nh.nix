{ config, ... }: let
  user = config.my.username;
in {
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 30d --keep 50";
    flake = "/home/${user}/nixcfg";
  };
}
