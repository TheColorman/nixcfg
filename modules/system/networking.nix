{ lib, config, pkgs, ... }: {
  nixpkgs.config.packageOverrides = pkgs: rec {
    wpa_supplicant = pkgs.wpa_supplicant.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ../patches/eduroam.patch ];
    });
  };

  networking = {
    hostName = "framework"; # @TODO: infer this
    networkmanager.enable = true;
    networkmanager.wifi.scanRandMacAddress = false;
    hosts = let
      base = { "10.42.0.4" = [ "pwnagotchi.local" ]; };
      tailscale = lib.optionalAttrs config.services.tailscale.enable { "192.168.50.222" = [ "truenas" ]; };
      full = base // tailscale;
    in full;
  };
}
