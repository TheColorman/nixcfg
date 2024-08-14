{ lib, config, osConfig, pkgs, ... }: let
	cfg = config.myHomeManager.oh-my-posh;
in {
	imports = [ ];
	
	options.myHomeManager.oh-my-posh = {
		enable = lib.mkEnableOption "Enable oh-my-posh config";
		enableZshIntegration = lib.mkEnableOption "Enable oh-my-posh zsh integration";
	};
	
	config = lib.mkIf cfg.enable {
		programs.oh-my-posh = {
			enable = true;
			enableBashIntegration = false;
			enableZshIntegration = false;
			enableFishIntegration = false;
			enableNushellIntegration = false;
		};
		programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration ''
			eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${osConfig.sops.templates."oh-my-posh-config.toml".path})"
		'';
	};
}