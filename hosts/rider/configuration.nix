{
  pkgs,
  outputs,
  config,
  ...
}: let
  username = "color";
in {
  imports = with outputs.modules; [
    ./hardware-configuration.nix
    common
    apps-btop
    apps-git
    apps-jujutsu
    apps-neovim
    apps-nix
    services-gpg
    services-sops
    services-tailscale
    system-networking
    utils-shell
    utils-shell-fish
    utils-nas_mounts
  ];

  my = {
    inherit username;
    stateVersion = "25.05";
  };

  environment.systemPackages = with pkgs; [vim];
  services.openssh.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    extraGroups = ["wheel"];
    packages = with pkgs; [
      fastfetch
      unzip
      p7zip
      aria2
      killall
      dig
      ripgrep
      cachix
      jq
    ];
  };

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Copenhagen";
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
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
  };

  # networking.interfaces."end0".ipv4.addresses = [
  #   {
  #     address = "192.168.50.58";
  #     prefixLength = 24;
  #   }
  # ];

  hardware.enableRedistributableFirmware = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
}
