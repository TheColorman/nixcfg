# Common configuration, assumed to be imported in all hosts
{ lib, pkgs, inputs, ... }: {
  imports = [ inputs.home-manager.nixosModules.default ];

  options.my.username = lib.mkOption
    {
      default = "color";
      description = ''
        Username used for home-manager configuration.
        It's used in custom modules to allow them to be imported by any user. This module is used as a dependency of any module that requires home-manager.
      '';
    };

  config = {
    # Allow execution of dynamic binaries
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged
      # programs here, NOT in environment.systemPackages
    ];
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    # Dynamic symlinks in /bin, useful for shebangs
    services.envfs.enable = true;

    users.mutableUsers = false;
  };
}
