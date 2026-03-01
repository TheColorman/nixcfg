{inputs, ...}: {
  flake.nixosModules.apps-affinity = {
    config,
    pkgs,
    ...
  }: {
    home-manager.users."${config.my.username}".home.packages = [
      inputs.affinity-nix.packages.${pkgs.stdenv.hostPlatform.system}.v3
    ];
  };
}
