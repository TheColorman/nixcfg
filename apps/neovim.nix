{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) getExe;
  inherit (config.my) username;

  nvim = inputs.nvfcfg.packages.${pkgs.system}.default;
in {
  environment.systemPackages = [nvim];

  home-manager.users.${username} = {
    home.sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };

    # Kitty integrations
    programs.kitty = {
      settings = {
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty.sock"; # TODO: Is this safe?
        shell_integration = "enabled";
      };

      # @TODO: This should really just be hardcoded, it's just 3 kitty mappings.
      #        Figure out how to get the path to kitty-scrollback.nvim so it
      #        can be hardcoded.
      extraConfig = ''
        # === kitty-scrollback.nvim config === #
        include ${(pkgs.runCommand "kitty-scrollback-generate.conf" {} ''
          export HOME=$PWD/home # neovim needs a home dir to load plugins and run next command
          ${getExe nvim} --headless +'redir! > $out' +'KittyScrollbackGenerateKittens' +'redir END' +'q'
        '')}
      '';
    };
  };
}
