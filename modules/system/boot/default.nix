{...}: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      configurationLimit = 50;
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
