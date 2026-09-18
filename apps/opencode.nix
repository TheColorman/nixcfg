{
  flake.nixosModules.apps-opencode =
    { config, pkgs, ... }:
    let
      # Pin to 'opencode: 1.18.30 -> 1.18.31'
      # https://github.com/NixOS/nixpkgs/pull/564320
      updated_pkgs = (
        import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/498495d7431a0df831f949ea31b5a3c8c5180951.tar.gz";
          sha256 = "sha256:1z2v6lawi7gmr5amzjjw4dwni0gj7gmn3df8x1y610gavmshkbgn";
        }) { inherit (pkgs.stdenv.hostPlatform) system; }
      );
    in
    {
      users.users."${config.my.username}".packages = [
        (updated_pkgs.opencode)
      ];
    };
}
