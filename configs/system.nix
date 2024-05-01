# For configuring nixos itself as well as default packages and their configuration
{pkgs, ...}: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # living on the edge
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-unstable";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Dynamic symlinks in /bin, useful for shebangs
  services.envfs.enable = true;

  environment.systemPackages = with pkgs; [
    ranger # for managing configs
    vim
    git
    gh
    gnupg
    alejandra
    zsh # good shell :3
    zoxide
    wget
    highlight
  ];

  environment.variables.EDITOR = "vim";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  home-manager.useUserPackages = true;

  # Allow execution of dynamic binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged
    # programs here, NOT in environment.systemPackages
  ];

  #   _____           _
  #  |  __ \         | |
  #  | |__) |_ _  ___| | ____ _  __ _  ___  ___
  #  |  ___/ _` |/ __| |/ / _` |/ _` |/ _ \/ __|
  #  | |  | (_| | (__|   < (_| | (_| |  __/\__ \
  #  |_|   \__,_|\___|_|\_\__,_|\__, |\___||___/
  #                              __/ |
  # ============================|___/============

  # ZSH
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [
      "git"
      "sudo"
      "aliases"
      "common-aliases"
      "gh"
      "history"
    ];
    theme = "eastwood";
  };

  # GPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
