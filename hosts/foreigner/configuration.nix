{
  pkgs,
  outputs,
  inputs,
  systemName,
  lib,
  ...
}: let
  username = "boarder";
in {
  imports = with outputs.modules; [
    inputs.nixos-wsl.nixosModules.default
    common
    apps-btop
    apps-git
    apps-jujutsu
    apps-neovim
    apps-nix
    apps-zellij
    services-docker
    services-gpg
    services-sops
    services-vscode-server
    system-locale-danish
    utils-shell
    utils-shell-fish
    utils-tmux
  ];
  my = {
    inherit username;
    stateVersion = "24.05";
  };
  networking.hostName = systemName;

  wsl = {
    enable = true;
    defaultUser = username;
  };

  # envfs is broken in wsl - makes system unbootable
  services.envfs.enable = lib.mkForce false;

  home-manager.users.${username}.programs.fish.shellAliases = {
    docker = "/run/current-system/sw/bin/docker";
  };

  services.gnome.gnome-keyring.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
    extraGroups = ["wheel" "dialout"];
    packages = with pkgs; [
      alejandra
      aria2
      attic-client
      dig
      fastfetch
      git-cliff
      glab
      killall
      nixd
      ranger
      ripgrep
      wl-clipboard
      wslu
    ];
  };

  security.pki.certificates = [
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").boarding.extraCerts
  ];

  time.timeZone = "Europe/Copenhagen";

  nixpkgs.hostPlatform = "x86_64-linux";
}
