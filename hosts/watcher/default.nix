{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.watcher = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      inputs.disko.nixosModules.disko

      watcher-configuration
      watcher-hardware-configuration
      watcher-disko-config

      {
        nixpkgs.hostPlatform = "x86_64-linux";
        networking.hostName = "watcher";
      }
    ];
  };
}
