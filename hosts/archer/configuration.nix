# configuration.nix
{
  config,
  pkgs,
  outputs,
  lib,
  ...
}: let
  username = "color";
in {
  imports = with outputs.modules; [
    ./hardware-configuration.nix
    common
    apps-claude-code
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
    services-yubikey
    services-docker
    services-gnome-keyring
    services-gpg
    services-kanata
    services-kdeconnect
    services-openfortivpn
    services-safeeyes
    services-sops
    services-syncthing
    services-tailscale
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

  networking.firewall.enable = lib.mkForce false;

  my = {
    inherit username;
    stateVersion = "23.11";

    hyprland.extraMonitorSettings = [
      ''
        {
          output=eDP-1
          mode=2256x1504
          position=0x0
          scale=1.333333
        }
      ''
      ''
        {
          output=desc:Lenovo Group Limited LEN T25d-10 VKDW2941
          mode=1920x1200
          position=-1920x0
          scale=auto
        }
      ''
      ''
        {
          output=desc:Lenovo Group Limited LEN T25d-10 VKMB6428
          mode=1920x1200
          position=-3840x0
          scale=auto
        }
      ''
      ''
        {
          output=desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047972
          mode=2560x1440@260
          position=1128x-1440
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
          output=desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047984
          mode=2560x1440@260
          position=-1128x-1440
          scale=auto
          bitdepth=10
          # > controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on,
          # > 2 - fullscreen only, 3 - fullscreen with video or game content type
          vrr=3
          supports_wide_color=1
        }
      ''
    ];
    syncthing.folders = {
      brain = {};
      CTF = {};
      Documents = {};
      ITU = {};
      projects = {};
    };
  };

  environment.systemPackages = with pkgs; [fprintd wl-clipboard];
  environment.etc.hosts.mode = "0644"; # Make hosts file writable
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = ["networkmanager" "wheel" "video"];
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
      fbterm
      jftui
      youtube-music
    ];
  };
  services = {
    fwupd.enable = true;
    fprintd.enable = true;
    power-profiles-daemon.enable = true;
    automatic-timezoned.enable = true;
  };

  time.timeZone = lib.mkDefault "Europe/Copenhagen";

  # @TODO: do I really need this? Did I add it for hotspots? Do hotspots need ipv4 forwarding? too scared to turn it off...
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;
}
