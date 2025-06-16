{
  pkgs,
  outputs,
  config,
  ...
}: let
  username = "color";
in {
  imports = with outputs.modules; [
    ./hardware-configuration.nix
    common
    apps-btop
    apps-git
    apps-jujutsu
    apps-neovim
    apps-nix
    services-autobrr
    services-cross-seed
    services-gpg
    services-hedgedoc
    services-immich
    services-jellyfin
    services-nextcloud
    services-prowlarr
    services-qbittorrent
    services-radarr
    services-recyclarr
    services-sonarr
    services-sops
    services-syncthing
    services-tailscale
    services-thelounge
    services-vaultwarden
    services-wakapi
    services-znc
    system-boot
    system-locale-danish
    system-networking
    utils-shell
    utils-shell-fish
  ];

  my = {
    inherit username;
    stateVersion = "25.05";
  };

  environment.systemPackages = with pkgs; [vim];
  services.openssh.enable = true;

  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    extraGroups = ["wheel"];
  };

  time.timeZone = "Europe/Copenhagen";

  # networking.interfaces."end0".ipv4.addresses = [
  #   {
  #     address = "192.168.50.58";
  #     prefixLength = 24;
  #   }
  # ];
}
