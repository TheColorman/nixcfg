# configuration.nix
{ config
, pkgs
, lib
, inputs
, outputs
, system
, ...
} @ meta:
let
  username = "color";
in
{
  imports = with outputs.modules; [
    ./hardware-configuration.nix
    profiles-common
    profiles-gaming
    profiles-plasma
    profiles-stylix
    profiles-yubikey
    system-emulation
    system-fonts
    system-networking
    apps-btop
    apps-fcitx5
    apps-git
    apps-gpg
    apps-hashcat
    apps-kdeconnect
    apps-kitty
    apps-libreoffice
    apps-mpv
    apps-neovim
    apps-nix
    apps-oh-my-posh
    apps-openfortivpn
    apps-safeeyes
    apps-sops
    apps-syncthing
    apps-tailscale
    apps-tmux
    apps-vesktop
    apps-vmware
    apps-vscode
    apps-zsh
    containers-hacking
  ];

  my.username = username;
  my.stylix.heliotheme = {
    enable = true;
    latitude = "-33.8582504248224";
    longitude = "151.21476416121257";
  };

  environment.systemPackages = with pkgs; [ fprintd ];
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      google-chrome
      obsidian
      fastfetch
      wireguard-tools
      firefox
      unzip
      p7zip
      ranger
      alejandra
      direnv
      zsh-autoenv
      inputs.fw-ectool.packages.x86_64-linux.fw-ectool
      aria2
      killall
      bottles
      dig
      nixpkgs-fmt
      ripgrep
    ];
  };

  services.fwupd.enable = true;
  services.fprintd.enable = true;
  services.input-remapper.enable = true; # @TODO get this shit to start on login or smthn
  hardware.bluetooth.enable = true;

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 50;
    };
    efi.canTouchEfiVariables = true;
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

  # Temporary
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  system.stateVersion = "23.11";
}
