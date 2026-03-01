{self, ...}: {
  flake.nixosModules.archer-configuration = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.my;
  in {
    imports = with self.nixosModules; [
      common
      apps-btop
      apps-evince
      apps-git
      apps-hashcat
      apps-jftui
      apps-jujutsu
      apps-kitty
      apps-mpv
      apps-neovim
      apps-nix
      apps-vesktop
      apps-vscode
      apps-waydroid
      apps-zellij
      profiles-gaming
      profiles-hacking
      profiles-office
      services-caelestia
      services-docker
      services-gpg
      services-kanata
      services-kdeconnect
      services-safeeyes
      services-sops
      services-syncthing
      services-tailscale
      services-yubikey
      system-audio
      system-bluetooth
      system-boot
      system-desktop-hyprland
      system-display
      system-locale-danish
      system-networking
      utils-emulation
      utils-shell
      utils-shell-fish
      utils-stylix
    ];

    my = {
      username = "color";
      stateVersion = "23.11";
      syncthing.folders = {
        brain = {};
        CTF = {};
        Documents = {};
        ITU = {};
        projects = {};
      };
    };

    environment = {
      systemPackages = [pkgs.fprintd];
      # Make hosts file writable
      etc.hosts.mode = "0644";
    };

    users.users."${cfg.username}" = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.color_passwd.path;
      description = "color";
      extraGroups = ["networkmanager" "wheel" "video"];
      packages = with pkgs; [
        aria2
        bottles
        cachix
        chromium
        dig
        fastfetch
        fbterm
        jq
        killall
        nixpkgs-fmt
        obsidian
        p7zip
        pear-desktop
        ripgrep
        telegram-desktop
        unzip
        wireguard-tools
      ];
    };

    services = {
      fwupd.enable = true;
      fprintd.enable = true;
      power-profiles-daemon.enable = true;
      automatic-timezoned.enable = true;
      upower.enable = true;
    };

    # Override the laptop monitor config to work with my various docks/desks
    home-manager.users."${cfg.username}".wayland.windowManager.hyprland.settings.monitorv2 = [
      {
        output = "eDP-1";
        mode = "2256x1504";
        position = "0x0";
        scale = "1.333333";
      }
      {
        output = "desc:Lenovo Group Limited LEN T25d-10 VKDW2941";
        mode = "1920x1200";
        position = "1920x0";
        scale = "auto";
      }
      {
        output = "desc:Lenovo Group Limited LEN T25d-10 VKMB6428";
        mode = "1920x1200";
        position = "3840x0";
        scale = "auto";
      }
      {
        output = "desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047984";
        mode = "2560x1440@240";
        position = "1128x-1440";
        scale = "auto";
        bitdepth = 10;
        # controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on,
        # 2 - fullscreen only, 3 - fullscreen with video or game content type
        vrr = 3;
        supports_wide_color = 1;
        supports_hdr = 1;
        sdr_min_luminance = 0.005;
        sdr_max_luminance = 200;
        min_luminance = 0.5;
        max_luminance = 400;
        max_avg_luminance = 350;
      }
      {
        output = "desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047972";
        mode = "2560x1440@240";
        position = "-1128x-1440";
        scale = "auto";
        bitdepth = 10;
        # controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on,
        # 2 - fullscreen only, 3 - fullscreen with video or game content type
        vrr = 3;
        supports_wide_color = 1;
        supports_hdr = 1;
        sdr_min_luminance = 0.005;
        sdr_max_luminance = 200;
        min_luminance = 0.5;
        max_luminance = 400;
        max_avg_luminance = 350;
      }
    ];
  };
}
