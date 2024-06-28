{...}: {
  # Patch for connecting to legacy eduroam networks
  nixpkgs.config.packageOverrides = pkgs: rec {
    wpa_supplicant = pkgs.wpa_supplicant.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches ++ [./patches/eduroam.patch];
    });
  };

  networking = {
    hostName = "framework";
    networkmanager.enable = true;
    hosts = {
      "192.168.50.222" = [ "truenas" ];
    };

    # Prevent networkmanager from managing nix containers
    networkmanager.unmanaged = ["interface-name:ve-*"];
  };
}
