{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.saber = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      saber-configuration
      saber-hardware-configuration

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "saber";
      }
    ];
  };
}
