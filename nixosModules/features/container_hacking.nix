{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.containers.hacking;
in
{
  options.myNixOS.containers.hacking = {
    enable = lib.mkEnableOption "Enable the hacking container";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.containers.meta.enable = true; # Enable ./containers.nix related settings

    environment.systemPackages = [ pkgs.xorg.xhost ];
    services.xserver.displayManager.setupCommands = "xhost +si:localuser:coolor";

    containers.hacking = {
      privateNetwork = true;
      hostAddress = "192.168.0.10";
      localAddress = "192.168.0.11";
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      config = { config, pkgs, ... }: {
        system.stateVersion = "24.05";
        nixpkgs.config.allowUnfree = true;
        system.autoUpgrade.channel = "https://nixos.org/channels/nixpkgs-unstable";

        environment = {
          etc.hosts.mode = "0644"; # Make hosts file writable

          systemPackages = with pkgs; [
            pwndbg
            firefox
            burpsuite
            python312Full
            python312Packages.pwntools
            nmap
            openvpn
            wireguard-tools
            ghidra-bin
            vim
            feroxbuster
            wireshark
          ];

          sessionVariables = {
            WAYLAND_DISPLAY = "wayland-0";
            XDG_RUNTIME_DIR = "/run/user/1000";
            DISPLAY = ":1";
            _JAVA_AWT_WM_NONREPARENTING = "1";
            _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
          };
        };

        programs.zsh.enable = true;

        users.users.cooler = {
          isNormalUser = true;
          home = "/home/cooler";
          extraGroups = [ "wheel" "networkmanager" ];
          uid = 1000;
          hashedPassword = "$y$j9T$VlePY7lc3CERuhGFmd1Tx1$24kMEO2sZA.fSplgA0FHQmFR.Q6S6ly8CLMGFzysKy0"; # TODO: make this a secret
          shell = pkgs.zsh;
        };

        hardware.graphics = {
          enable = true;
          # extraPackages = config.hardware.graphics.extraPackages;
        };

        systemd.services.fix-run-permission = {
          script = ''
            #!${pkgs.stdenv.shell}
            set -euo pipefail

            chown cooler:users /run/user/1000
            chmod u=rwx /run/user/1000
          '';
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
          };
        };
      };

      bindMounts = {
        home = {
          hostPath = "/home/color/projects/hack_container";
          isReadOnly = false;
          mountPoint = "/home/cooler";
        };
        # Enable GUI using host
        waylandDisplay = rec {
          hostPath = "/run/user/1000";
          mountPoint = hostPath;
        };
        x11Display = rec {
          hostPath = "/tmp/.X11-unix";
          mountPoint = hostPath;
          isReadOnly = true;
        };
      };
 
      enableTun = true; # Allow starting VPN connections
    };
  };
}
