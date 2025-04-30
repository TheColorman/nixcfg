{
  outputs,
  pkgs,
  config,
  ...
}: let
  user = "color";
in {
  imports = with outputs.modules; [
    common
    apps-btop
    apps-git
    apps-neovim
    services-gpg
    services-kanata
    services-sops
    services-tailscale
    system-fonts
    system-networking
    utils-shell
    utils-stylix
    utils-emulation
    utils-direnv
    utils-fzf
    utils-shell-oh-my-posh
    utils-tmux
  ];

  my.username = user;

  nixpkgs.hostPlatform = {system = "x86_64-linux";};

  users.users.${user} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      fastfetch
      wireguard-tools
      unzip
      p7zip
      ranger
      aria2
      killall
      dig
      ripgrep
    ];
  };

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "da_DK.UTF-8";
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

  system.stateVersion = "25.05";
}
