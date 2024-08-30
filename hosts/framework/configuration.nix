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
    profiles-stylix-default
    system-fonts
    system-japanese
    system-networking
    apps-git
    apps-kdeconnect
    apps-kitty
    apps-libreoffice
    apps-mpv
    apps-nix
    apps-oh-my-posh
    apps-openfortivpn
    apps-sops
    apps-syncthing
    apps-tailscale
    apps-tmux
    apps-vesktop
    apps-vim
    apps-vmware
    apps-zsh
    containers-hacking
  ];

  my.username = username;

  environment.systemPackages = with pkgs; [ fprintd ];
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      google-chrome
      vscode
      obsidian
      fastfetch
      wireguard-tools
      firefox
      unzip
      btop
      p7zip
      ranger
      alejandra
      direnv
      zsh-autoenv
      inputs.fw-ectool.packages.x86_64-linux.fw-ectool
      aria2
      mangohud
      killall
      bottles
      safeeyes
      dig
      nixpkgs-fmt
      ripgrep
    ];
  };

  services.fwupd.enable = true;
  services.fprintd.enable = true;
  services.input-remapper.enable = true; # @TODO get this shit to start on login or smthn
  hardware.bluetooth.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 100;
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

  system.stateVersion = "23.11";
  system.nixos.label = "update-nixpkgs";
}
