{outputs, ...}: {
  imports = [outputs.homeManagerModules.default];

  home = {
    username = "color";
    homeDirectory = "/home/color";
    stateVersion = "23.11";
  };

  myHomeManager = {
    zsh.enable = true;
    kitty = {
      enable = true;
      enableTmuxIntegration = true;
    };
    gaming.enable = true;
    kdeconnect.enable = true;
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
    };
    tmux.enable = true;
    vim.enable = true;
    stylix.enable = true;
    vesktop.enable = true;
    mpv.enable = true;
  };
}
