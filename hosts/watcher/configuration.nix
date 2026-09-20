{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.watcher-configuration =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my;
    in
    {
      imports = with self.nixosModules; [
        common
        apps-btop
        apps-git
        apps-jujutsu
        apps-ki
        apps-neovim
        apps-nix
        profiles-language-servers
        services-gpg
        services-kanata
        services-sops
        services-tailscale
        system-boot
        system-certs
        system-locale-danish
        system-networking
        utils-shell-fish
      ];

      my = {
        username = "color";
        stateVersion = "26.11";
      };

      users.users."${cfg.username}" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.color_passwd.path;
        description = "color";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = with pkgs; [
          inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.default

          aria2
          cachix
          dig
          fastfetch
          jq
          killall
          nixpkgs-fmt
          p7zip
          ripgrep
          unzip
          wireguard-tools
        ];
      };

      services = {
        fwupd.enable = true;
        power-profiles-daemon.enable = true;
        automatic-timezoned.enable = true;
        upower.enable = true;
      };
    };
}
