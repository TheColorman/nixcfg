{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) getExe;
  inherit (config.my) username;

  nvim =
    if config ? stylix && config.stylix.enable
    # Override with stylix theme if stylix is enabled
    then
      inputs.nvfcfg.override.${pkgs.system}.default ({lib, ...}:
        with config.lib.stylix.colors; {
          vim = {
            theme = {
              name = lib.mkForce "base16";
              transparent = true;
              base16-colors = {
                inherit
                  base00
                  base01
                  base02
                  base03
                  base04
                  base05
                  base06
                  base07
                  base08
                  base09
                  base0A
                  base0B
                  base0C
                  base0D
                  base0E
                  base0F
                  ;
              };
            };
            # Telescope colors look ass with in default base16
            # This gives everything transparent background
            luaConfigRC.extraHighlights = lib.nvim.dag.entryAfter ["theme" "highlight" "pluginConfigs"] ''
              vim.api.nvim_set_hl(0, "TelescopeBorder", {fg="#${base08}"})
              vim.api.nvim_set_hl(0, "TelescopeNormal", {fg="#${base05}"})
              vim.api.nvim_set_hl(0, "TelescopePromptBorder", {fg="#${base0F}"})
              vim.api.nvim_set_hl(0, "TelescopePromptNormal", {fg="#${base04}"})
              vim.api.nvim_set_hl(0, "TelescopeResultsTitle", {fg="#${base04}"})
            '';
          };
        })
    # Else use default theme
    else inputs.nvfcfg.packages.${pkgs.system}.default;
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
