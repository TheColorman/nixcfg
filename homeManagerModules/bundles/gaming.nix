{ lib, config, pkgs, ... }: let
	cfg = config.myHomeManager.gaming;
in {
	imports = [ ];
	
	options.myHomeManager.gaming.enable = lib.mkEnableOption "Enable gaming configs";
	
	config = lib.mkIf cfg.enable {
		home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
		home.packages = [ pkgs.protonup ];
	};
}