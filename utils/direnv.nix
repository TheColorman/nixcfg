{
  flake.nixosModules.utils-direnv = {config, ...}: let
    inherit (config.my) username;
    inherit (config.home-manager.users.${username}.programs) zsh;
  in {
    home-manager.users."${username}".programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      enableZshIntegration = zsh.enable;
    };
  };
}
