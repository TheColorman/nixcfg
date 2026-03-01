{
  flake.nixosModules.system-desktop-xserver = {
    services.xserver = {
      enable = true;
      xkb.layout = "us";
    };
    console.useXkbConfig = true;
  };
}
