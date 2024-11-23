{...}: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      configurationLimit = 40;
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
