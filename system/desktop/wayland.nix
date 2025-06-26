{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  # basic graphic
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
