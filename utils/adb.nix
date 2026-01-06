{
  config,
  pkgs,
  ...
}: let
  user = config.my.username;
in {
  environment.systemPackages = [
    pkgs.android-tools
  ];
  users.users.${user}.extraGroups = ["adbusers"];
}
