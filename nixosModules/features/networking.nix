{ lib, config, ... }: let
	cfg = config.myNixOS.networking;
in {
	imports = [ ];

	options.myNixOS.networking.enable = lib.mkEnableOption "Enable networking";

	config = lib.mkIf cfg.enable {
		nixpkgs.config.packageOverrides = pkgs: rec {
			wpa_supplicant = pkgs.wpa_supplicant.overrideAttrs (oldAttrs: {
				patches = (oldAttrs.patches or []) ++ [./patches/eduroam.patch];
			});
		};

		networking = {
			hostName = "framework";
			networkmanager.enable = true;
			hosts = { "192.168.50.222" = [ "truenas" ]; };
		};
	};
}