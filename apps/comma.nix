{ self, ... }:
{
  flake.nixosModules.apps-comma = {
    imports = [ self.nixosModules.apps-nix-index ];

    programs.nix-index-database.comma.enable = true;
  };
}
