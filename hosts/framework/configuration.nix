# configuration.nix
{
  pkgs,
  inputs,
  system,
  ...
}: let
  pkg = name: inputs.${name}.packages.${system}.default;
in {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./user-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "color" = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    python312Packages.pygments
    input-remapper
    aria2
    (pkg "fw-ectool")
    fprintd
  ];

  environment.pathsToLink = ["/share/zsh"];
  services.input-remapper.enable = true;
  services.fwupd.enable = true;
  # we need fwupd 1.9.7 to downgrade the fingerprint sensor firmware
  services.fwupd.package = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
    sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
  }) {
    inherit (pkgs) system;
  }).fwupd;
  hardware.bluetooth.enable = true;
}
