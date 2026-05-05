{
  flake.nixosModules.apps-lutris =
    { config, ... }:
    let
      inherit (config.my) username;
    in
    {
      home-manager.users."${username}".programs.lutris.enable = true;
    };
}
