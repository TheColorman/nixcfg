{ inputs, ... }:
{
  flake.nixosModules.apps-affinity =
    {
      config,
      pkgs,
      ...
    }:
    {
      nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

      home-manager.users."${config.my.username}".home.packages = [
        pkgs.affinity-v3
      ];
    };
}
