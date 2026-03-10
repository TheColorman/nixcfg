{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.pretender = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      pretender-configuration
      pretender-hardware-configuration

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "pretender";
      }
    ];
  };
}
