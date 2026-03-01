{
  flake.nixosModules.apps-kitty = {
    lib,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (config.my) username;

    home = config.home-manager.users."${username}";
    inherit (home.programs) tmux zsh;

    hasLaunchConfig = home.xdg.configFile."kitty/launch.conf".enable or false;
  in {
    home-manager.users."${config.my.username}" = {
      programs.kitty = {
        enable = true;
        settings = {
          # font.name = "CaskaydiaCove Nerd Font"; # Now managed by stylix
          scrollback_lines = 10000;
          enable_audio_bell = false;
          confirm_os_window_close = 0;
          background_blur = 1;
          hide_window_decorations = true;
          cursor_trail = 3;

          startup_session = mkIf hasLaunchConfig "launch.conf";
        };

        keybindings = {
          "ctrl+c" = "copy_or_interrupt";
          "ctrl+shift+u" = ""; # kitty overrides the system unicode input
          "ctrl+shift+alt+u" = "kitten unicode_input"; # so add alt to the combo
        };

        shellIntegration.enableZshIntegration = zsh.enable;
      };

      # Auto start tmux in kitty, with new sessions that share windows
      xdg.configFile = mkIf tmux.enable {
        "kitty/launch.conf".text = ''
          launch sh -c "tmux new -t main" -2
        '';
      };
    };
  };
}
