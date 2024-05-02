# configuration.nix
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default

    ../../modules/nixos/bootloader.nix # Generic bootloader - grub tbd
    ../../modules/nixos/plasma.nix # Desktop environment
    ../../modules/nixos/locale.nix # Danish UTF-8 locale for rendering
    ../../modules/nixos/networking.nix # Networkmanager
    ../../modules/nixos/nix.nix # General nixos config
    ../../modules/nixos/shell.nix # Global zsh, might make this user-based for home-manager management
    ../../modules/nixos/snix.nix # Script used to version control nix config
    # Legacy modules
    ../../modules/nixos/legacy/user.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "color" = import ./home.nix;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];
}
