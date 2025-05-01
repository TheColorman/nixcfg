{
  config,
  outputs,
  pkgs,
  ...
}: let
  inherit (config.my) username;
in {
  imports = with outputs.modules; [
    apps-libreoffice
  ];

  users.users.${username}.packages = with pkgs; [
    xournalpp
  ];
}
