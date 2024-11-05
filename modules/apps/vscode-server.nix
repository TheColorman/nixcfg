{
  lib,
  pkgs,
  ...
}: {
  # TODO: figure out how to only define these options if they exist
  wsl.extraBin = [
    {src = lib.getExe' pkgs.coreutils "dirname";}
    {src = lib.getExe' pkgs.coreutils "readlink";}
    {src = lib.getExe' pkgs.coreutils "uname";}
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };
}
