{
  flake.nixosModules.services-yubikey = {pkgs, ...}: {
    services = {
      udev.packages = [pkgs.yubikey-personalization];
      pcscd.enable = true;
    };
  };
}
