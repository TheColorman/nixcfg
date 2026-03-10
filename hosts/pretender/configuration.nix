{self, ...}: {
  flake.nixosModules.pretender-configuration = {
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
      apps-zellij
      services-gpg
      services-kanata
      services-sops
      system-boot
      system-locale-danish
      utils-shell-fish
    ];

    my = {
      username = "color";
      stateVersion = "25.11";
    };

    services.openssh.enable = true;

    users.users."${cfg.username}" = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.color_passwd.path;
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        fastfetch
        killall
        dig
        ripgrep
        cachix
        attic-client
        jq
      ];
    };

    time.timeZone = "Europe/Copenhagen";

    hardware.enableRedistributableFirmware = true;
  };
}
