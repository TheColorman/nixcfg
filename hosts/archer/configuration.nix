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
    services-yubikey
    services-docker
    services-gpg
    services-kanata
    services-kdeconnect
    services-openfortivpn
    services-safeeyes
    services-sops
    services-syncthing
    services-tailscale
    system-audio
    system-desktop-hyprland
    system-boot
    system-display
    system-networking
    utils-shell
    utils-stylix
    utils-emulation
    utils-nas_mounts
    utils-adb
    utils-shell-oh-my-posh
  ];

  my = {
    inherit username;
    stateVersion = "23.11";

    hyprland.extraMonitorSettings = [
      "eDP-1,   2256x1504,     0x0, 1.333333"
      "desc:Lenovo Group Limited LEN T25d-10 VKDW2941, 1920x1200, -1920x0, auto"
      "desc:Lenovo Group Limited LEN T25d-10 VKMB6428, 1920x1200, -3840x0, auto"
    ];
  };

  environment.systemPackages = with pkgs; [fprintd wl-clipboard];
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
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;
}
