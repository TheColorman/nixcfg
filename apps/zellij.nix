{config, ...}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".programs.zellij = {
    enable = true;
    attachExistingSession = true;
    exitShellOnExit = true;
    enableFishIntegration = config.home-manager.users."${username}".programs.fish.enable;
  };
}
