{
  flake.nixosModules.apps-libreoffice = {pkgs, ...}: {
    nixpkgs.overlays = [
      (_final: _prev: {
        inherit
          (import (fetchTarball {
              # TODO: Remove once 494721 reaches nixos-unstable
              # Libreoffice build failure fixed in
              # - https://github.com/NixOS/nixpkgs/pull/494721
              url = "https://github.com/nixos/nixpkgs/archive/b097075bf24c9c9d3d2a0f6978effd7f150d2a89.tar.gz";
              sha256 = "sha256:0z3jfcf75zli4fqam2inca280hxw17kncx8v6psyik65c11sg1rc";
            }) {
              inherit (pkgs.stdenv.hostPlatform) system;
            })
          libreoffice
          ;
      })
    ];

    fonts.packages = with pkgs; [carlito];
    environment.systemPackages = with pkgs; [libreoffice];
  };
}
