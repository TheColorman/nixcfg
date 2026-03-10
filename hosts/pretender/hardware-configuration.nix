{
  flake.nixosModules.pretender-hardware-configuration = {
    lib,
    modulesPath,
    config,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      initrd.kernelModules = [];
      kernelModules = ["kvm-intel"];
      extraModulePackages = [];
    };
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/ecb2acca-f3ab-449a-b207-542274da7e81";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/7404-4980";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
