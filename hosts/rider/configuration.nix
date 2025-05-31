{
  pkgs,
  outputs,
  ...
}: let
  user = "color";
in {
  imports = with outputs.modules; [
    ./hardware-configuration.nix
    common
    apps-btop
    apps-git
    apps-jujutsu
    apps-neovim
    apps-nix
    system-networking
    utils-shell
    utils-shell-fish
  ];

  environment.systemPackages = with pkgs; [vim];

  services.openssh.enable = true;

  my.stateVersion = "25.05";

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$Vl8jrClizkWjKwA/x42xH1$nYnTieowMq7SnXB.Qfibf8IFs6iuYkozM5myB.WjPb5";
      extraGroups = ["wheel"];
    };
  };

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
