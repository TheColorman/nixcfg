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
      lib,
      ...
    }:
    let
      cfg = config.my;
    in
    {
      imports = with self.nixosModules; [
        inputs.nixos-hardware.nixosModules.huawei-machc-wa
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable

        common
        apps-btop
        apps-git
        apps-jujutsu
        apps-ki
        apps-neovim
        apps-nix
        profiles-language-servers
        services-airtrail
        services-cloudflared
        services-dawarich
        services-gpg
        services-home-assistant
        services-kanata
        services-nginx
        services-opencode
        services-postfix
        services-sops
        services-tailscale
        services-trek
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
        automatic-timezoned.enable = true;
        upower.enable = true;
        openssh.enable = true;

        # Disable suspend when closing lid
        logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
          HandleLidSwitchDocked = "ignore";
        };

        # Control battery charge limits
        tlp.enable = true;
      };

      boot = {
        kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.all.forwarding" = 1;
        };
        kernelParams = [
          "consoleblank=300"
        ];
      };

      # See https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/nvidia/prime.nix
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce false;
        powerManagement = {
          enable = lib.mkForce false;
          finegrained = lib.mkForce false;
        };
      };
    };
}
