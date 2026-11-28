{ inputs, ... }: {
  flake.nixosModules.apps-photocraft =
    { pkgs, config, ... }:
    let
      inherit (config.my) username;
    in
    {
      nixpkgs.overlays = [ inputs.photocraft.overlays.default ];

      home-manager.users."${username}".home.packages = [
        pkgs.photocraft
      ];
    };
}
