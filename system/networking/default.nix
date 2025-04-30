{
  lib,
  config,
  systemName,
  ...
}: {
  options.my.network.ignoreDeauth = lib.mkEnableOption "whether to ignore deauth packets";

  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      wpa_supplicant = pkgs.wpa_supplicant.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or []) ++ [./eduroam.patch];
      });
    };

    networking = {
      hostName = systemName;
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
      wireless.extraConfig = ''
        ignore_deauth=${builtins.toString config.my.network.ignoreDeauth}
      '';
    };

    services.resolved.enable = true;
  };
}
