{
  flake.nixosModules.caster-hardware-configuration = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
    boot = {
      initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"];
      initrd.kernelModules = [];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/d1889212-5c90-471b-a466-e0fd1d19bfc9";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/A2D1-4BDC";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };

      "/mnt/appsies" = {
        device = "/dev/disk/by-uuid/5a7d1612-db24-464b-9314-2bb957bdf8e8";
        fsType = "ext4";
        neededForBoot = true;
      };

      "/var/lib" = {
        depends = ["/mnt/appsies"];
        device = "/mnt/appsies/var/lib";
        fsType = "none";
        options = ["bind"];
      };

      "/nix" = {
        depends = ["/mnt/appsies"];
        device = "/mnt/appsies/nix";
        fsType = "none";
        options = ["bind" "noatime"];
        neededForBoot = true;
      };
    };

    swapDevices = [];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
