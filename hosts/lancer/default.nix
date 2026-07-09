{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.lancer = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      inputs.disko.nixosModules.disko

      lancer-configuration
      lancer-disko-config

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "lancer";
      }
    ];
  };
}
