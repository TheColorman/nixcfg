{pkgs,...}: {
  environment.systemPackages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];
}