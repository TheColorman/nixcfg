{
  config,
  pkgs,
  ...
}: let
  inherit (config.my) username;
in {
  nixpkgs.config.allowUnfree = true;

  home-manager.users.${username} = {
    home.packages = [
      pkgs.burpsuite
    ];
  };
}
