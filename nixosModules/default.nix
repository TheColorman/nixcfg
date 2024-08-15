{ inputs, pkgs, ... }: {
  imports = [ inputs.home-manager.nixosModules.default ] ++ [
    ./features/stylix/default.nix
    ./features/bluetooth.nix
    ./features/container_hacking.nix
    ./features/containers.nix
    ./features/fonts.nix
    ./features/git.nix
    ./features/gpg.nix
    ./features/hyprland.nix
    ./features/input-remapper.nix
    ./features/japanese.nix
    ./features/kdeconnect.nix
    ./features/libreoffice.nix
    ./features/networking.nix
    ./features/oh-my-posh.nix
    ./features/openfortivpn.nix
    ./features/plasma.nix
    ./features/sops.nix
    ./features/syncthing.nix
    ./features/tailscale.nix
    ./features/vmware.nix
    ./features/zsh.nix
  ] ++ [
    ./bundles/gaming.nix
    ./bundles/home-manager.nix
    ./bundles/xserver.nix
  ];

  options.myNixOS = { };

  config = {
    # Allow execution of dynamic binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged
      # programs here, NOT in environment.systemPackages
    ];
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    system.autoUpgrade = {
      enable = true;
      allowReboot = false;
      channel = "https://channels.nixos.org/nixos-unstable";
    };

    # Dynamic symlinks in /bin, useful for shebangs
    services.envfs.enable = true;

    users.mutableUsers = false;
  };
}
