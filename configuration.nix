# configuration.nix
{...}: {
  imports = [
    /etc/nixos/hardware-configuration.nix # Include the results of the hardware scan.
    <home-manager/nixos>
    ./configs/bootloader.nix
    ./configs/networking.nix
    ./configs/locale.nix
    ./configs/system.nix
    ./configs/desktop.nix
    ./configs/user.nix
  ];
}
