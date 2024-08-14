{ lib, inputs, config, pkgs, ... }: let
	cfg = config.myNixOS.sops;
in {
	imports = [ inputs.sops-nix.nixosModules.sops ];

	options.myNixOS.sops.enable = lib.mkEnableOption "Enable sops config";

	config = lib.mkIf cfg.enable {
		environment.systemPackages = [ pkgs.age ];

		sops = {
			defaultSopsFile = "${builtins.toString inputs.nix-secrets}/secrets.yaml";
			age = {
				sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
				keyFile = "/var/lib/sops-nix/key.txt";
				generateKey = true;
			};
			secrets = {
				color_passwd = { neededForUsers = true; };
				lastfm_auth = { owner = config.users.users.color.name; };
				tailscale_auth = {};
			};
		};
	};
}