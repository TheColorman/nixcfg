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
    services-beszel-agent
    services-beszel-hub
    services-cross-seed
    services-ersatztv
    services-gpg
    services-hedgedoc
    services-homepage
    services-immich
    services-isponsorblocktv
    services-jellyfin
    services-jellyseerr
    services-minecraft-server
    services-nextcloud
    services-nginx
    services-playit
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
    services-zitadel
    services-znc
    system-boot
    system-certs
    system-locale-danish
    system-networking
    utils-shell
    utils-shell-fish
  ];

  my = {
    inherit username;
    stateVersion = "25.05";
    beszel = {
      sopsSecrets = {
        key = "services/beszel/agent/caster/key";
        token = "services/beszel/agent/caster/token";
      };
      extraEnvironment = {
        EXTRA_FILESYSTEMS = "/mnt/neodata/default,/mnt/appsies";
      };
    };
    syncthing = {
      # Disable creating syncthing folders in ${username}'s home directory and
      # bindfs mounting those into the Syncthing dataDir.
      enableMounts = false;
      folders = {
        brain = {};
        "Creative Cloud" = {};
        ITU = {};
        nbns = {};
        Documents = {};
        CTF = {};
        Games = {};
        projects = {};
      };
    };
  };

  environment.systemPackages = with pkgs; [vim];
  services = {
    # Pinned postgres version
    postgresql.package = pkgs.postgresql_17;

    openssh.enable = true;
    zfs.autoScrub = {
      enable = true;
      pools = ["neodata"];
    };
  };

  users.users."${username}" = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.color_passwd.path;
    extraGroups = ["wheel"];
  };

  boot = {
    supportedFilesystems.zfs = true;
    zfs.extraPools = ["neodata"];
  };
  networking = {
    # Required by ZFS
    hostId = "2fe34f2d";
    firewall.allowedTCPPorts = [
      # Syncthing WebUI
      8384
      # TheLounge WebUI
      9000
    ];
  };

  time.timeZone = "Europe/Copenhagen";
}
