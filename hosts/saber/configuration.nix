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
    ./disko-config.nix
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
          output=desc:ASUSTek COMPUTER INC VG27AQM1A T1LMQS047972
          mode=2560x1440@144
          position=-2560x0
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
          mode=2560x1440@144
          position=0x0
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
    # hashedPasswordFile = config.sops.secrets.color_passwd.path;
    hashedPassword = "$y$j9T$q3r9SIWSdbAOy1SKJIB2I1$kuka1Q3uggA0yQZjFlxkaldl6iNVzsmRtdZCjEvn8N2";
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

  sops.secrets = {
    system-key-pub = {
      path = "/etc/ssh/ssh_host_ed25519_key.pub";
      key = "hosts/saber/ssh/pub";
    };
    system-key-priv = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      key = "hosts/saber/ssh/priv";
    };
    user-key-pub = {
      path = "/home/${username}/.ssh/id_ed25519.pub";
      key = "hosts/saber/ssh/pub";
      owner = username;
    };
    user-key-priv = {
      path = "/home/${username}/.ssh/id_ed25519";
      key = "hosts/saber/ssh/priv";
      owner = username;
    };
    "hosts/saber/sops_key" = {
      path = "/home/${username}/.config/sops/age/keys.txt";
      owner = username;
    };
  };
  services.fwupd.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
