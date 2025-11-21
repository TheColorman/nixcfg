# configuration.nix
{
  config,
  pkgs,
  outputs,
  ...
}: let
  username = "color";
in {
  imports = with outputs.modules; [
    ./hardware-configuration.nix
    common
    apps-affinity
    apps-btop
    apps-evince
    apps-deploy-rs
    apps-feh
    apps-git
    apps-hashcat
    apps-jftui
    apps-jujutsu
    apps-kitty
    apps-mpv
    apps-neovim
    apps-nix
    apps-vesktop
    apps-virt-manager
    apps-vscode
    apps-waydroid
    apps-zellij
    apps-zen-browser
    profiles-gaming
    profiles-hacking
    profiles-office
    services-caelestia
    services-docker
    services-gnome-keyring
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
    system-certs
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
    inherit username;
    stateVersion = "24.05";
    syncthing.folders = {
      brain = {};
      CTF = {};
      Documents = {};
      projects = {};
      Games = {};
    };
  };

  environment.etc.hosts.mode = "0644"; # Make hosts file writable
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      aria2
      bottles
      cachix
      chromium
      dig
      fastfetch
      jq
      killall
      nixpkgs-fmt
      obsidian
      p7zip
      prismlauncher
      ripgrep
      signal-desktop
      speed-cloudflare-cli
      telegram-desktop
      unzip
      wireguard-tools
      youtube-music
    ];
  };

  services = {
    openssh.enable = true;
    fwupd.enable = true;
  };

  time.timeZone = "Europe/Copenhagen";
  home-manager = {
    users."${username}" = {
      programs = {
        # Saber does not have a battery.
        caelestia.settings.bar.status.showBattery = false;

        # btop rocm for AMD GPU
        btop.package = pkgs.btop-rocm;
      };

      wayland.windowManager.hyprland.settings.monitorv2 = [
        {
          output = "desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047984";
          mode = "2560x1440@240";
          position = "0x0";
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
          position = "2560x0";
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
  };
}
