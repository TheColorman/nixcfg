{ self, inputs, ... }:
{
  flake.nixosModules.pretender-configuration =
    {
      pkgs,
      config,
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
        apps-git
        apps-jujutsu
        apps-kitty
        apps-neovim
        apps-nix
        services-gpg
        services-kanata
        services-sops
        system-boot
        system-desktop-hyprland
        system-display
        system-locale-danish
        utils-shell-fish
      ];

      my = {
        username = "color";
        stateVersion = "25.11";
      };

      services.openssh.enable = true;

      networking.firewall.enable = lib.mkForce false;

      users.users."${cfg.username}" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.color_passwd.path;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = with pkgs; [
          attic-client
          cachix
          chromium
          dig
          fastfetch
          iperf
          jq
          killall
          python313
          ripgrep
          usbutils
        ];
      };

      security.pki.certificates = [
        (import "${inputs.nix-secrets}/evaluation-secrets.nix").pretender.extraCerts
      ];

      time.timeZone = "Europe/Copenhagen";

      hardware.enableRedistributableFirmware = true;
    };
}
