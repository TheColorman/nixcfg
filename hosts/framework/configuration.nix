# configuration.nix
{ config
, pkgs
, lib
, inputs
, outputs
, system
, ...
} @ meta: {
  imports = [ ./hardware-configuration.nix ];

  myNixOS = {
    username = "color";
    userConfig = ./home.nix;

    bluetooth.enable = true;
    containers.hacking.enable = true;
    git.enable = true;
    gpg.enable = true;
    input-remapper.enable = true;
    japanese.enable = true;
    kdeconnect.enable = true;
    oh-my-posh.enable = true;
    sops.enable = true;
    syncthing.enable = true;
    tailscale.enable = true;
    zsh.enable = true;
    stylix.enable = true;
    fonts.enable = true;
    networking.enable = true;
    openfortivpn.enable = true;
    plasma.enable = true;
    vmware.enable = false;
    libreoffice.enable = true;
    nixcfg.enable = true;
  };

  environment.systemPackages = with pkgs; [ fprintd ];

  services.fwupd.enable = true;
  services.fprintd.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.users.color = {
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
      fprintd
      mangohud
      killall
      bottles
      mpv
      safeeyes
      dig
      nixpkgs-fmt
    ];
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
  system.nixos.label = "add-configuration-limit";
}
