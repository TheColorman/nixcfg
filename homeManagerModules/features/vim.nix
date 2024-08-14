{ lib, config, pkgs, ... }: let
	cfg = config.myHomeManager.vim;
in {
	imports = [ ];
	
	options.myHomeManager.vim.enable = lib.mkEnableOption "Enable vim config";
	
	config = lib.mkIf cfg.enable {
		home = {
			packages = [ pkgs.vim ];
			sessionVariables.EDITOR = "vim";
		};
	};
}