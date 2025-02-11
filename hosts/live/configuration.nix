{ outputs, pkgs, config, ... }: let
  user = "color";
in {
  imports = with outputs.modules; [
    profiles-common
    profiles-shell
    profiles-stylix
    system-emulation
    system-fonts
    system-networking
    apps-btop
    apps-direnv
    apps-fcitx5
    apps-fzf
    apps-git
    apps-gpg
    apps-kanata
    apps-neovim
    apps-oh-my-posh
    apps-sops
    apps-tailscale
    apps-tmux
  ];

  my.username = user;

  nixpkgs.hostPlatform = { system = "x86_64-linux"; };
  
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
