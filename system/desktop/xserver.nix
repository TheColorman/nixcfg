{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  console.useXkbConfig = true;

  # 32-bit application support
  hardware.graphics.enable32Bit = true;
}
