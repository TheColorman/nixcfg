{self, ...}: {
  flake.nixosModules.profiles-office = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.my) username;
  in {
    imports = with self.nixosModules; [
      apps-libreoffice
    ];

    users.users.${username}.packages = with pkgs; [
      xournalpp
    ];
  };
}
