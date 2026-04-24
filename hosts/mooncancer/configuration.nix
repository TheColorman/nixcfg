{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.mooncancer-configuration =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my;
    in
    {
      imports = with self.nixosModules; [
        inputs.nixos-wsl.nixosModules.default
        common
        apps-btop
        apps-git
        apps-jujutsu
        apps-ki
        apps-neovim
        apps-nix
        profiles-language-servers
        services-docker
        services-gpg
        services-sops
        services-vscode-server
        system-locale-danish
        utils-shell-fish
        utils-tmux
      ];

      my = {
        username = "color";
        stateVersion = "25.11";
      };

      wsl = {
        enable = true;
        defaultUser = cfg.username;
      };
      services = {
        # envfs is broken in wsl - makes system unbootable
        envfs.enable = lib.mkForce false;
        gnome.gnome-keyring.enable = true;

        xserver.videoDrivers = [ "nvidia" ];
      };

      hardware = {
        graphics.enable = true;
        nvidia.open = true;
        # TODO: haven't been able to get this to work in WSL yet
        # nvidia-container-toolkit.enable = true;
      };

      home-manager.users."${cfg.username}".programs.fish.shellAliases = {
        docker = "/run/current-system/sw/bin/docker";
        k = "kubectl";
      };

      environment.systemPackages = with pkgs; [
        kmod
        nvidia-container-toolkit
      ];

      users.users."${cfg.username}" = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
        extraGroups = [
          "wheel"
          "dialout"
        ];
        packages = with pkgs; [
          alejandra
          aria2
          attic-client
          dig
          fastfetch
          fluxcd-operator
          git-cliff
          glab
          kubectl
          kubernetes-helm
          killall
          niks3
          nixd
          nixfmt
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
