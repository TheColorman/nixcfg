{self, ...}: {
  flake.nixosModules.rider-configuration = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.my;
  in {
    imports = with self.nixosModules; [
      common
      apps-btop
      apps-git
      apps-jujutsu
      apps-neovim
      apps-nix
      # services-anchorr
      # services-anki-sync-server
      # services-argonone
      services-beszel-agent
      # services-discord-portal
      # services-factbot
      # services-firefox-syncserver
      services-gpg
      services-sops
      services-tailscale
      # services-technitium
      system-bluetooth
      system-certs
      system-locale-danish
      system-networking
      utils-shell
      utils-shell-fish
    ];

    my = {
      username = "color";
      stateVersion = "25.05";

      beszel.sopsSecrets = {
        key = "services/beszel/agent/rider/key";
        token = "services/beszel/agent/rider/token";
      };
    };

    environment.systemPackages = with pkgs; [vim];
    services.openssh.enable = true;

    users.users."${cfg.username}" = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.color_passwd.path;
      extraGroups = ["wheel"];
      packages = with pkgs; [
        fastfetch
        unzip
        p7zip
        aria2
        killall
        dig
        ripgrep
        cachix
        jq
      ];
    };

    time.timeZone = "Europe/Copenhagen";

    hardware.enableRedistributableFirmware = true;

    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
      initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
    };
  };
}
