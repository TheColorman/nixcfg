{
  inputs,
  config,
  systemPlatform,
  ...
}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".home.packages = [
    inputs.affinity-nix.packages.${systemPlatform}.v3
  ];
}
