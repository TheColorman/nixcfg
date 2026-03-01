{
  flake.nixosModules.system-networking = {
    lib,
    config,
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
        networkmanager.enable = true;
        networkmanager.wifi.scanRandMacAddress = false;
        nameservers = ["1.1.1.1"];

        # bitches trying to deauth me n shit
        wireless.extraConfig = ''
          ignore_deauth=${builtins.toString config.my.network.ignoreDeauth}
        '';
      };

      services.resolved.enable = true;
    };
  };
}
