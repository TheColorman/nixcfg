{ config, outputs, pkgs, ... }: let
  user = config.my.username;
in {
  imports = with outputs.modules; [
    apps-libreoffice
  ];

  users.users.${user}.packages = with pkgs; [
    xournalpp
  ];
}
