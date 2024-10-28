{...}: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      configurationLimit = 50;
    };
    efi.canTouchEfiVariables = true;
  };
}
