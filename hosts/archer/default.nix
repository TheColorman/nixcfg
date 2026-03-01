{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.archer = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      archer-configuration
      archer-hardware-configuration

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "archer";
      }
    ];
  };
}
