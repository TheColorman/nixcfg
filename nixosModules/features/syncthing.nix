{ lib, config, pkgs, ... }: let
	cfg = config.myNixOS.syncthing;
	owner = "color";
in {
	imports = [ ];

	options.myNixOS.syncthing.enable = lib.mkEnableOption "Enable Syncthing";

	config = lib.mkIf cfg.enable {
		services.syncthing = {
			enable = true;
			openDefaultPorts = true;
			settings.devices = {
				"colordesktop" = {
					addresses = [ "dynamic" ];
					id = "MCFUD3B-ZCXDBVJ-H243LXH-V3N6CEK-IT6PW6E-2EMYKH2-FURKLOT-546OQAQ";
				};
				"colorcloud" = {
					addresses = [ "tcp://192.168.50.222:20978"  "tcp://192.168.50.222:20979"
												"quic://192.168.50.222:20978" "quic://192.168.50.222:20979" ];
					id = "HRE2PWX-SNH52Z7-4YWWZRK-GX5IJ5V-SNYBZOY-P4NHNWC-TDBV5ZY-MKZLKA7";
				};
				"colorphone" = {
					addresses = [ "dynamic" ];
					id = "FUHS52Q-W6FORIW-OP4737B-RI5FP4Z-KCHL3U6-C2CF7HG-OKMQAU6-AJJYOA3";
				};
			};
			settings.folders = {
				brain = {
					devices = [ "colordesktop" "colorcloud" "colorphone" ];
					id = "yedar-6vrrr";
					path = "/home/${owner}/brain";
				};
				CTF = {
					devices = [ "colordesktop" "colorcloud" ];
					id = "dh6gy-zxqu6";
					path = "/home/${owner}/CTF";
				};
				ITU = {
					devices = [ "colordesktop" "colorcloud" ];
					id = "yc39s-4wtgc";
					path = "/home/${owner}/ITU";
				};
				Documents = {
					devices = [ "colordesktop" "colorcloud" "colorphone" ];
					id = "wt32c-t7rkv";
					path = "/home/${owner}/Documents";
				};
			};
		};
		system.activationScripts.syncthingSetup.text = ''
			mkdir -p /home/${owner}/brain
			mkdir -p /home/${owner}/CTF
			mkdir -p /home/${owner}/ITU
			mkdir -p /home/${owner}/Documents

			setfacl=${pkgs.acl}/bin/setfacl

			$setfacl -Rdm u:syncthing:rwx /home/${owner}/brain
			$setfacl -Rdm u:syncthing:rwx /home/${owner}/CTF
			$setfacl -Rdm u:syncthing:rwx /home/${owner}/ITU
			$setfacl -Rdm u:syncthing:rwx /home/${owner}/Documents
			$setfacl -Rm u:syncthing:rwx /home/${owner}/brain
			$setfacl -Rm u:syncthing:rwx /home/${owner}/CTF
			$setfacl -Rm u:syncthing:rwx /home/${owner}/ITU
			$setfacl -Rm u:syncthing:rwx /home/${owner}/Documents

			$setfacl -Rdm u:${owner}:rwx /home/${owner}/brain
			$setfacl -Rdm u:${owner}:rwx /home/${owner}/CTF
			$setfacl -Rdm u:${owner}:rwx /home/${owner}/ITU
			$setfacl -Rdm u:${owner}:rwx /home/${owner}/Documents
			$setfacl -Rm u:${owner}:rwx /home/${owner}/brain
			$setfacl -Rm u:${owner}:rwx /home/${owner}/CTF
			$setfacl -Rm u:${owner}:rwx /home/${owner}/ITU
			$setfacl -Rm u:${owner}:rwx /home/${owner}/Documents

			$setfacl -m u:syncthing:--x /home/${owner}
		'';
		environment.systemPackages = with pkgs; [ syncthing ];
	};
}