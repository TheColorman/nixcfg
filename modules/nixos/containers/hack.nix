# https://nixos.wiki/wiki/NixOS_Containers

{ pkgs, ... }: {
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
      # Make hosts file writable
      etc.hosts.mode = "0644";

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
      };
    };

    programs.zsh.enable = true;

    users.users.col0r = {
      isNormalUser = true;
      home = "/home/col0r";
      extraGroups = [ "wheel" "networkmanager" ];
      uid = 1000;
      hashedPassword = "$y$j9T$VlePY7lc3CERuhGFmd1Tx1$24kMEO2sZA.fSplgA0FHQmFR.Q6S6ly8CLMGFzysKy0";
      shell = pkgs.zsh;
    };

    hardware.opengl = {
      enable = true;
    };
  };

  bindMounts = {
    home = {
      hostPath = "/home/color/projects/hack_container";
      isReadOnly = false;
      mountPoint = "/home/col0r";
    };
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
  enableTun = true;
}
