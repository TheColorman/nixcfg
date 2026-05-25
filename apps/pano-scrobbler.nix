{ inputs, ... }:
{
  flake.nixosModules.apps-pano-scrobbler =
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (config.my) username;
    in
    {
      nixpkgs.overlays = [
        (_final: prev: {
          pano-scrobbler = inputs.pano-scrobbler.packages.${prev.stdenv.hostPlatform.system}.default;
        })
      ];

      home-manager.users."${username}".home.packages = [ pkgs.pano-scrobbler ];
    };
}
