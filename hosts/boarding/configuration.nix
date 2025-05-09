{
  pkgs,
  outputs,
  inputs,
  ...
}: let
  username = "boarder";
in {
  imports = with outputs.modules; [
    common

    inputs.nixos-wsl.nixosModules.default

    apps-btop
    apps-git
    apps-jujutsu
    apps-neovim
    apps-nix
    services-docker
    services-gpg
    services-sops
    services-vscode-server
    utils-shell
    utils-shell-oh-my-posh
    utils-tmux
  ];
  my = {
    inherit username;
    stateVersion = "24.05";
  };
  networking.hostName = "boarding";

  wsl = {
    enable = true;
    wslConf = {
      # @TODO: Broken
      automount.root = "/mnt";
      interop.appendWindowsPath = false;
      network.generateHosts = false;
    };
    defaultUser = username;
    startMenuLaunchers = true;

    # docker-desktop.enable = true;
  };

  home-manager.users.${username}.programs.zsh.shellAliases = {
    docker = "/run/current-system/sw/bin/docker";
  };

  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
    extraGroups = ["wheel" "dialout"];
    packages = with pkgs; [
      fastfetch
      ranger
      aria2
      killall
      dig
      ripgrep
      alejandra
      nixd
    ];
  };

  security.pki.certificates = [
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").boarding.extraCerts
  ];

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
