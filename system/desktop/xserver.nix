{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
    };

    # Enable CUPS to print documents.
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  console.useXkbConfig = true;

  # 32-bit application support
  hardware.graphics.enable32Bit = true;
}
