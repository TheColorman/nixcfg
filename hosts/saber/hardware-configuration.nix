{
  flake.nixosModules.saber-hardware-configuration = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
      initrd.kernelModules = [];
      kernelModules = ["kvm-amd"];
      extraModulePackages = [];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/deb9b618-c83e-4600-9802-94be15bb8417";
        fsType = "ext4";
      };

      "/bin" = {
        device = "/usr/bin";
        fsType = "none";
        options = ["bind"];
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/30E7-B53D";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
    };

    swapDevices = [];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
    # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
    # networking.interfaces.tailscale0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
