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
    services-anki-sync-server
    services-discord-portal
    services-factbot
    services-firefox-syncserver
    services-gpg
    services-requestrr
    services-sops
    services-tailscale
    system-locale-danish
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

  hardware.enableRedistributableFirmware = true;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  # Rider has started depending on rocm-smi during the evaluation of its system
  # config, but rocm-smi only supports x86_64. How this dependency was
  # introduced I have no idea, but compiling rocm-smi on aarch64 works just
  # fine, so perhaps someone should add it to the supported systems?
  nixpkgs.config.allowUnsupportedSystem = true;
}
