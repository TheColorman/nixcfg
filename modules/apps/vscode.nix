{ config, ... }: {
  home-manager.users."${config.my.username}".programs.vscode = {
    enable = true;

    # extensions = []; # @TODO
    mutableExtensionsDir = true;
  };
}
