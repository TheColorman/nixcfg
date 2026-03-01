# Common configuration, assumed to be imported in all hosts
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.common = {
    lib,
    pkgs,
    config,
    ...
  }: let
    cfg = config.my;
  in {
    imports = [
      inputs.home-manager.nixosModules.default
      self.nixosModules.apps-comma
      self.nixosModules.apps-nix-output-monitor
    ];

    options.my = {
      username = lib.mkOption {
        default = "color";
        description = ''
          Username used for home-manager configuration.
          It's used in custom modules to allow them to be imported by any user.
          This module is used as a dependency of any module that requires
          home-manager.
        '';
      };
      stateVersion = lib.mkOption {
        type = lib.types.str;
        description = "System and home-manager state version";
      };
    };

    config = {
      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          # flakes
          experimental-features = ["nix-command" "flakes" "pipe-operators"];
          # allow main user to trust binary caches among other things
          trusted-users = ["root" cfg.username];

          trusted-substituters = [
            "https://cache.nixos.org"
            "https://hyprland.cachix.org"
            "https://cache.garnix.io"
            "https://cache.flox.dev"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
          ];
        };

        # A flake registry is a repository that contains a nix flake. This
        # attrset specifies system-wide registries and their aliases. For
        # example, the nixpkgs alias, which by default points to
        # github:nixos/nixpkgs/master, is here set to instead point to the
        # nixpkgs revision used in this system flake. This prevents the system
        # from trying to fetch the newest nixpkgs revision every time I try do
        # `nix run nixpkgs#` or `nix shell nixpkgs#`.
        registry = {
          nixpkgs = {
            from = {
              id = "nixpkgs";
              type = "indirect";
            };
            flake = inputs.nixpkgs;
          };
          nur.to = {
            owner = "nix-community";
            repo = "nur";
            type = "github";
          };
        };
      };
      # Allow execution of dynamic binaries
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [libsecret];
      };

      services = {
        envfs.enable = true; # /bin symlinks for shebangs
        printing.enable = true;
      };
      hardware.graphics.enable32Bit = true; # 32-bit application support

      environment.systemPackages = with pkgs; [
        aria2
        bat
        cachix
        dig
        dust
        fastfetch
        fd
        file
        jq
        killall
        noto-fonts
        noto-fonts-cjk-sans
        nh
        p7zip
        ripgrep
        ripgrep-all
        sd
        tealdeer
        unzip
        uutils-coreutils-noprefix
        xh
        yazi
      ];

      users.mutableUsers = false;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";

        users."${cfg.username}" = {
          programs.home-manager.enable = true;

          home = {
            inherit (cfg) username stateVersion;
            homeDirectory = "/home/${cfg.username}";
          };
        };
      };
      system = {
        inherit (cfg) stateVersion;
        configurationRevision =
          self.rev or (builtins.warn
            "Git tree may be dirty, build will not have a tracked revision!"
            null);
      };
    };
  };
}
