{...}: {
  boot.loader = {
    grub = {
      enable = true;
      useOSProber = true;
      device = "nodev";
      configurationLimit = 50;
    };
    efi.canTouchEfiVariables = true;
  };
}
