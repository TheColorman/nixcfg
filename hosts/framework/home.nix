{
  config,
  pkgs,
  inputs,
  ...
}@meta: let
  # Imports a home manager module from the home-manager dir
  mod = name: (import "${inputs.this.outPath}/modules/home-manager/${name}.nix" meta);
  file = name: "${inputs.this.outPath}/modules/home-manager/${name}";
in {
  home.username = "color";
  home.homeDirectory = "/home/color";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.file = {
    ".p10k.zsh".source = ./dotfiles/p10k.zsh;
    ".config/kitty/launch.conf".source = file "kitty/launch_tmux.conf";
  };

  home.sessionVariables = {
    EDITOR = "vim";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    GDK_SCALE = 2; # Steam scaling
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    zsh = mod "zsh";
    kitty = mod "kitty/kitty";
    tmux = mod "tmux";
    fzf = mod "fzf";
  };

  home.packages = with pkgs; [
    protonup # GAMING
  ];
}
