# configuration.nix
{
  config,
  pkgs,
  outputs,
  inputs,
  ...
}: let
  username = "boarder";
in {
  imports = with outputs.modules; [
    inputs.nixos-wsl.nixosModules.default

    profiles-common
    profiles-shell
    system-fonts
    apps-btop
    apps-git
    apps-gpg
    apps-neovim
    apps-nix
    apps-oh-my-posh
    apps-vscode-server
  ];

  my.username = username;
  networking.hostName = "boarding";

  wsl.enable = true;
  wsl.defaultUser = username;

  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
    extraGroups = ["wheel"];
    packages = with pkgs; [
      fastfetch
      ranger
      aria2
      killall
      dig
      ripgrep
    ];
  };

  time.timeZone = "Australia/Sydney";
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
  system.stateVersion = "24.05";
}
