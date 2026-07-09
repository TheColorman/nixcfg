{ self, ... }:
{
  flake.nixosModules.lancer-configuration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.my;
    in
    {
      imports = with self.nixosModules; [
        common
        apps-btop
        apps-evince
        apps-git
        apps-hashcat
        apps-jftui
        apps-jujutsu
        apps-ki
        apps-kitty
        apps-mpv
        apps-neovim
        apps-nix
        apps-pano-scrobbler
        apps-vesktop
        apps-virt-manager
        apps-vscode
        apps-zen-browser
        profiles-gaming
        profiles-hacking
        profiles-office
        services-caelestia
        services-docker
        services-gpg
        services-kanata
        services-kdeconnect
        services-safeeyes
        # services-sops
        services-tailscale
        services-yubikey
        system-audio
        system-bluetooth
        # system-certs
        system-desktop-hyprland
        system-display
        system-locale-danish
        system-networking
        utils-emulation
        utils-shell-fish
        utils-stylix
      ];

      my = {
        username = "color";
        stateVersion = "26.05";
      };

      # Make hosts file writable
      environment.etc.hosts.mode = "0644";

      users.users."${cfg.username}" = {
        isNormalUser = true;
        # To be changed after first boot
        password = "changeme!";
        # hashedPasswordFile = config.sops.secrets.color_passwd.path;
        description = "color";
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
        ];
        packages = with pkgs; [
          aria2
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

      # Options to make portable drive work across different hardware
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = false;
      };
      hardware.enableAllHardware = true;

      services = {
        fwupd.enable = true;
        power-profiles-daemon.enable = true;
        automatic-timezoned.enable = true;
        upower.enable = true;
      };

      home-manager.users."${cfg.username}" = {
        programs.caelestia.settings.bar.status = {
          # Lancer probably has a battery and Wi-Fi.
          showBattery = true;
          showWifi = true;
        };
      };
    };
}
