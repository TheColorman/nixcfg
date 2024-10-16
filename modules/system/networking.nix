{
  lib,
  config,
  ...
}: {
  options.my.network.ignoreDeauth = lib.mkEnableOption "whether to ignore deauth packets";

  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      wpa_supplicant = pkgs.wpa_supplicant.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or []) ++ [../patches/eduroam.patch];
      });
    };

    networking = {
      hostName = "framework"; # @TODO: infer this
      networkmanager.enable = true;
      networkmanager.wifi.scanRandMacAddress = false;
      hosts = let
        base = {"10.42.0.4" = ["pwnagotchi.local"];};
        tailscale = lib.optionalAttrs config.services.tailscale.enable {"192.168.50.222" = ["truenas"];};
        full = base // tailscale;
      in
        full;
      nameservers = ["192.168.50.58" "1.1.1.1"];

      # bitches trying to deauth me n shit
      wireless.extraConfig = lib.optionalString config.my.network.ignoreDeauth ''
        ignore_deauth=1
      '';
    };
  };
}
