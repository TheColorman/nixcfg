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
    apps-gaming
    apps-office
    apps-btop
    apps-git
    apps-hashcat
    apps-jujutsu
    apps-kitty
    apps-mpv
    apps-neovim
    apps-nix
    apps-vesktop
    apps-vscode
    apps-waydroid
    apps-zellij
    profiles-hacking
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
    system-desktop-hyprland
    system-display
    system-locale-danish
    system-networking
    utils-shell
    utils-stylix
    utils-emulation
    utils-nas_mounts
    utils-shell-fish
  ];

  my = {
    inherit username;
    stateVersion = "24.05";

    hyprland.extraMonitorSettings = [
      ''
        {
          output=desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047984
          mode=2560x1440@260
          position=0x0
          scale=auto
          bitdepth=10
          # > controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on,
          # > 2 - fullscreen only, 3 - fullscreen with video or game content type
          vrr=3
          supports_wide_color=1
        }
      ''
      ''
        {
          output=desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047972
          mode=2560x1440@260
          position=2560x0
          scale=auto
          bitdepth=10
          # > controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on,
          # > 2 - fullscreen only, 3 - fullscreen with video or game content type
          vrr=3
          supports_wide_color=1
        }
      ''
    ];
  };

  environment.etc.hosts.mode = "0644"; # Make hosts file writable
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      obsidian
      fastfetch
      wireguard-tools
      unzip
      p7zip
      ranger
      aria2
      killall
      bottles
      dig
      nixpkgs-fmt
      ripgrep
      cachix
      jq
      floorp
    ];
  };

  services.openssh.enable = true;

  services.fwupd.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
