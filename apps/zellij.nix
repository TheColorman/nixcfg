{config, ...}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".programs.zellij = {
    enable = true;
    attachExistingSession = true;
    exitShellOnExit = true;
  };
}
