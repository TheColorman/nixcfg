{
  config,
  pkgs,
  outputs,
  lib,
  ...
}: let
  username = "color";
in {
  imports = with outputs.modules; [
    common
    apps-btop
    apps-git
    apps-jujutsu
    apps-neovim
    apps-nix
    profiles-hacking
    services-docker
    services-kanata
    services-sops
    services-tailscale
    system-locale-danish
    system-networking
    utils-shell
    utils-emulation
    utils-shell-fish
  ];

  networking.firewall.enable = lib.mkForce false;

  my = {
    inherit username;
    stateVersion = "24.05";
  };

  environment.etc.hosts.mode = "0644"; # Make hosts file writable
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      fastfetch
      wireguard-tools
      unzip
      p7zip
      aria2
      killall
      dig
      nixpkgs-fmt
      ripgrep
      cachix
      jq
      fbterm
    ];
  };
  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Copenhagen";

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader.generic-extlinux-compatible.enable = true;
  };
}
