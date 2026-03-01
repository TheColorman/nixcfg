{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.caster = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      caster-configuration
      caster-hardware-configuration

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "caster";
      }
    ];
  };
}
