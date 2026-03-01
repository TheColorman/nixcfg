{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.rider = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      rider-configuration
      rider-hardware-configuration

      {
        nixpkgs.hostPlatform = "aarch64-linux";
        networking.hostName = "rider";
      }
    ];
  };
}
