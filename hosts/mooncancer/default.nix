{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.mooncancer = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      mooncancer-configuration

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "mooncancer";
      }
    ];
  };
}
