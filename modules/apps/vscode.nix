{ config, pkgs, ... }: {
  users.users.${config.my.username}.packages = with pkgs; [
    vscode
    nil
    alejandra
  ];
 #  home-manager.users."${config.my.username}".programs.vscode = {
 #    enable = true;

    # extensions = []; # @TODO
 #    mutableExtensionsDir = true;
 #  };
}
