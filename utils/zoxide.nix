{config, ...}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".programs.zoxide = {
    enable = true;
    options = [
      "--cmd cd"
    ];
  };
}
