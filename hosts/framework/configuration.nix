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
    profiles-common
    profiles-gaming
    profiles-plasma
    profiles-shell
    profiles-stylix
    profiles-workspace
    profiles-yubikey
    system-boot
    system-display
    system-emulation
    system-fonts
    system-networking
    apps-adb
    apps-btop
    apps-docker
    apps-fcitx5
    apps-git
    apps-gpg
    apps-hashcat
    apps-kanata
    apps-kdeconnect
    apps-kitty
    apps-mpv
    apps-neovim
    apps-nix
    apps-oh-my-posh
    apps-openfortivpn
    apps-safeeyes
    apps-sops
    apps-syncthing
    apps-tailscale
    apps-tmux
    apps-vesktop
    apps-vscode
    apps-waydroid
    containers-hacking
  ];

  my.username = username;
  my.stylix.heliotheme = {
    enable = true;
    latitude = "-33.8582504248224";
    longitude = "151.21476416121257";
  };

  environment.systemPackages = with pkgs; [fprintd];
  environment.etc.hosts.mode = "0644"; # Make hosts file writable
  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      google-chrome
      obsidian
      fastfetch
      wireguard-tools
      firefox
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
      nextcloud-client
    ];
  };
  services = {
    fwupd.enable = true;
    fprintd.enable = true;
    power-profiles-daemon.enable = true;
  };
  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # @TODO: do I really need this? Did I add it for hotspots? Do hotspots need ipv4 forwarding? too scared to turn it off...
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  system.stateVersion = "23.11";
}
