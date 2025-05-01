{config, ...}: let
  user = config.my.username;
in {
  programs.adb.enable = true;
  users.users.${user}.extraGroups = ["adbusers"];
}
