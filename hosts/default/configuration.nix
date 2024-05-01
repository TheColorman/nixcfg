# configuration.nix
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/bootloader.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/user.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "color" = import ./home.nix;
    };
  };
}
