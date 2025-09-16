{
  pkgs,
  outputs,
  inputs,
  systemName,
  ...
}: let
  username = "nixos";
in {
  imports = with outputs.modules; [
    inputs.nixos-wsl.nixosModules.default
    common
    # apps-btop
    # apps-claude-code
    # apps-git
    # apps-jujutsu
    # apps-neovim
    # apps-nix
    # apps-zellij
    # services-docker
    # services-gpg
    # services-sops
    # services-vscode-server
    # system-locale-danish
    # utils-shell
    # utils-shell-fish
    # utils-tmux
  ];
  my = {
    inherit username;
    stateVersion = "24.05";
  };
  # networking.hostName = systemName;
  networking.hostName = "nixos";

  wsl = {
    enable = true;
    defaultUser = username;
  };

  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
    extraGroups = ["wheel"];
    packages = with pkgs; [
      alejandra
      aria2
      attic-client
      dig
      fastfetch
      glab
      killall
      nixd
      ranger
      ripgrep
      wl-clipboard
      wslu
    ];
  };

  # time.timeZone = "Europe/Copenhagen";

  nixpkgs.hostPlatform = "x86_64-linux";
}
