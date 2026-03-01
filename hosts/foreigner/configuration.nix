{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.foreigner-configuration = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.my;
  in {
    imports = with self.nixosModules; [
      inputs.nixos-wsl.nixosModules.default
      common
      apps-btop
      apps-git
      apps-jujutsu
      apps-neovim
      apps-nix
      apps-zellij
      services-docker
      services-gpg
      services-sops
      services-vscode-server
      system-locale-danish
      utils-shell
      utils-shell-fish
      utils-tmux
    ];
    my = {
      username = "boarder";
      stateVersion = "24.05";
    };

    wsl = {
      enable = true;
      defaultUser = cfg.username;
    };

    # envfs is broken in wsl - makes system unbootable
    services.envfs.enable = lib.mkForce false;

    home-manager.users."${cfg.username}".programs.fish.shellAliases = {
      docker = "/run/current-system/sw/bin/docker";
      k = "kubectl";
    };

    services.gnome.gnome-keyring.enable = true;

    users.users."${cfg.username}" = {
      isNormalUser = true;
      hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
      extraGroups = ["wheel" "dialout"];
      packages = with pkgs; [
        alejandra
        aria2
        attic-client
        dig
        fastfetch
        fluxcd
        git-cliff
        glab
        kubectl
        kubernetes-helm
        killall
        nixd
        ripgrep
        wl-clipboard
        wslu
      ];
    };

    security.pki.certificates = [
      (import "${inputs.nix-secrets}/evaluation-secrets.nix").boarding.extraCerts
    ];

    time.timeZone = "Europe/Copenhagen";
  };
}
