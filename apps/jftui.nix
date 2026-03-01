{
  flake.nixosModules.apps-jftui = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.my) username;
    mpv = config.home-manager.users."${username}".programs.mpv.package;
  in {
    users.users."${username}".packages = [
      (pkgs.jftui.override {inherit mpv;})
    ];
  };
}
