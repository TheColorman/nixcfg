{ config, pkgs, ... }:
{
  home-manager.users."${config.my.username}" = {
    programs.tmux = {
      enable = true;
      clock24 = true;
      customPaneNavigationAndResize = true;
      keyMode = "vi";
      mouse = true;
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [ urlview tmux-thumbs tmux-fzf ];
      extraConfig = ''
        bind -Tcopy-mode WheelUpPane send -N1 -X scroll-up
        bind -Tcopy-mode WheelDownPane send -N1 -X scroll-down

        # split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %

        # switch panes using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # don't rename windows automatically
        set-option -g allow-rename off

        # STYLING
        # clock mode
        setw -g clock-mode-colour colour1

        # copy mode
        setw -g mode-style 'fg=colour1 bg=colour18 bold'

        # pane borders
        set -g pane-border-style 'fg=colour1'
        set -g pane-active-border-style 'fg=colour3'

        # statusbar
        set -g status-position bottom
        set -g status-justify left
        set -g status-style 'fg=colour1'
        set -g status-left '''
        set -g status-right '#{weather}| #{battery_icon} #{battery_percentage} | %Y-%m-%d %H:%M '
        set -g status-right-length 50
        set -g status-left-length 10

        setw -g window-status-current-style 'fg=colour0 bg=colour1 bold'
        setw -g window-status-current-format ' #I #W #F '

        setw -g window-status-style 'fg=colour1 dim'
        setw -g window-status-format ' #I #[fg=colour7]#W #[fg=colour1]#F '

        setw -g window-status-bell-style 'fg=colour2 bg=colour1 bold'

        # messages
        set -g message-style 'fg=colour2 bg=colour0 bold'

        # Plugins that need to be loaded after their configuration
        run-shell ${pkgs.tmuxPlugins.weather}/share/tmux-plugins/weather/weather.tmux
        run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/battery/battery.tmux
      '';
    };
  };
}
