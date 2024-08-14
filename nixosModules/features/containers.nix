{ lib, config, ... }: let
	cfg = config.myNixOS.containers.meta;
in {
	options.myNixOS.containers.meta = {
		enable = lib.mkEnableOption "Enable configs to make nixos containers work";
	};

	config = lib.mkIf cfg.enable {
		networking = {
			nat = {
				enable = true;
				internalInterfaces = [ "ve-+" ];
				externalInterface = "wlp1s0";
				enableIPv6 = true;
			};
      # Prevent networkmanager from managing nix containers
			networkmanager.unmanaged = ["interface-name:ve-*"];
		};
	};
}