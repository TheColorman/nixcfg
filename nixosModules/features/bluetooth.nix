{ lib, config, ... }: {
	imports = [ ];
	
	options.myNixOS.bluetooth.enable = lib.mkEnableOption "Enable bluetooth";
	
	config = lib.mkIf config.myNixOS.bluetooth.enable {
		hardware.bluetooth.enable = true;
	};
}