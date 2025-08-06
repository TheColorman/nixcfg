{
  pkgs,
  outputs,
  inputs,
  systemName,
  ...
}: let
  username = "boarder";
in {
  imports = with outputs.modules; [
    inputs.nixos-wsl.nixosModules.default
    common
    apps-btop
    apps-claude-code
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
    wslConf = {
      interop.appendWindowsPath = false;
      network.generateHosts = false;
    };
    defaultUser = username;
    startMenuLaunchers = true;
  };

  home-manager.users.${username}.programs.fish.shellAbbrs = {
    docker = "/run/current-system/sw/bin/docker";
  };

  services.gnome.gnome-keyring.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
    extraGroups = ["wheel" "dialout"];
    packages = with pkgs; [
      attic-client
      fastfetch
      ranger
      aria2
      killall
      dig
      ripgrep
      alejandra
      nixd
      glab
      wslu
    ];
  };

  security.pki.certificates = [
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").boarding.extraCerts
  ];

  time.timeZone = "Europe/Copenhagen";

  nixpkgs.hostPlatform = "x86_64-linux";
}
