{ lib, config, pkgs, inputs, outputs, ... }:
let
  hostUsername = config.my.username;
  guestUsername = "col0r";
in

{
  imports = [ outputs.modules.containers-common ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "hack";
      runtimeInputs = with pkgs; [ xorg.xhost ];
      text = ''
        nixos-container start hacking
        xhost local:
        nixos-container login hacking
      '';
    })
  ];

   containers.hacking = {
    privateNetwork = true;
    hostAddress = "192.168.0.10";
    localAddress = "192.168.0.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    specialArgs = { inherit inputs outputs; };
    config = { lib, pkgs, outputs, ... }:
      let
        pwndbg = inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in {
        imports = with outputs.modules; [
          profiles-common
          apps-git
          apps-neovim
          apps-oh-my-posh
          apps-sops
          apps-vscode
          apps-zsh
        ];

        my.username = guestUsername;

        nixpkgs.config.allowUnfree = true;

        home-manager.users."${guestUsername}".home.stateVersion = lib.mkForce "24.05";

        system.stateVersion = "24.05";

        users.users."${guestUsername}" = {
          isNormalUser = true;
          hashedPassword = "$y$j9T$VlePY7lc3CERuhGFmd1Tx1$24kMEO2sZA.fSplgA0FHQmFR.Q6S6ly8CLMGFzysKy0"; # TODO: make this a secret
          extraGroups = [ "networkmanager" "wheel" ];
          packages = with pkgs; [
            firefox
            burpsuite
            python312Full
            python312Packages.pwntools
            nmap
            openvpn
            wireguard-tools
            ghidra-bin
            feroxbuster
            wireshark
            ffuf
            binwalk
            exiftool
          ] ++ [ pwndbg ];
          uid = 1000;
        };
        environment = {
          etc.hosts.mode = " 0644 "; # Make hosts file writable

          sessionVariables = {
            WAYLAND_DISPLAY = "wayland-0";
            XDG_RUNTIME_DIR = "/run/user/1000";
            DISPLAY = ":1";
            _JAVA_AWT_WM_NONREPARENTING = "1";
            _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
          };
        };

        boot.binfmt.emulatedSystems = [
          "i686-windows"
          "x86_64-windows"
          "aarch64-linux"
          "aarch64_be-linux"
          "armv6l-linux"
          "armv7l-linux"
          "loongarch64-linux"
        ];

        networking.firewall.enable = false;
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        systemd.services.fix-run-permission = {
          script = ''
            #!${pkgs.stdenv.shell}
            set - euo pipefail

            chown ${guestUsername}:users /run/user/1000
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
        hostPath = "/home/${hostUsername}/projects/hack_container";
        mountPoint = "/home/${guestUsername}/shared";
        isReadOnly = false;
      };
      # Enable GUI using host
      waylandDisplay = {
        hostPath = "/run/user/1000";
        mountPoint = "/run/user/1000";
        isReadOnly = false; # uh-oh spaggheti-o's
      };
      x11Display = {
        hostPath = "/tmp/.X11-unix";
        mountPoint = "/tmp/.X11-unix";
        isReadOnly = true;
      };
      oh-my-posh-config = rec {
        hostPath = "/run/secrets-rendered/oh-my-posh-config.toml";
        mountPoint = hostPath;
        isReadOnly = true;
      };
      CTF = lib.mkIf config.services.syncthing.enable {
        hostPath = "/home/${hostUsername}/CTF";
        mountPoint = "/home/${guestUsername}/CTF";
        isReadOnly = false;
      };
    };

    enableTun = true; # Allow starting VPN connections
  };
}


