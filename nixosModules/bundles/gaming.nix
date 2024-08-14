{ lib, config, ... }: let
	cfg = config.myNixOS.gaming;
in {
	imports = [ ];
	
	options.myNixOS.gaming.enable = lib.mkEnableOption "Enable gaming configs";
	
	config = lib.mkIf cfg.enable {
		programs = {
			steam = {
				enable = true;
				gamescopeSession.enable = true;
				protontricks.enable = true;
			};
  		gamemode.enable = true;
		};
	};
}