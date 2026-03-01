{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.foreigner = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      foreigner-configuration

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "foreigner";
      }
    ];
  };
}
