{ lib, config, pkgs, ... }: {
  nixpkgs.config.packageOverrides = pkgs: rec {
    wpa_supplicant = pkgs.wpa_supplicant.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ../patches/eduroam.patch ];
    });
  };

  networking = {
    hostName = "framework";
    networkmanager.enable = true;
    hosts = lib.mkIf config.services.tailscale.enable
      { "192.168.50.222" = [ "truenas" ]; };
  };
}
