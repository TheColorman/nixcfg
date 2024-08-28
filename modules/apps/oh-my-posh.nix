{ lib, config, pkgs, ... }:
let
  cfg = config.my.oh-my-posh;
  zshEnabled = config.home-manager.users."${config.my.username}".programs.zsh.enable;
in
{
  # This module requires importing apps-sops in configuration.nix to work.
  # See https://github.com/NixOS/nix/issues/7270
  # imports = with outputs.modules; [ apps-sops ];

  home-manager.users."${config.my.username}" = {
    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
    };
    programs.zsh.initExtra = lib.mkIf zshEnabled ''
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.sops.templates."oh-my-posh-config.toml".path})"
    '';
  };

  sops.templates."oh-my-posh-config.toml" = {
    owner = config.users.users."${config.my.username}".name;
    content = ''
      #:schema https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json

      version = 2
      final_space = true
      console_title_template = '{{ .Shell }} in {{ .Foldir }}'

      [[blocks]]
        type = 'prompt'
        alignment = 'left'
        newline = true

        [[blocks.segments]]
          type = 'os'
          style = 'plain'
          background = 'transparent'
          template = '{{ .Icon }}  '

        [[blocks.segments]]
          type = 'path'
          style = 'plain'
          foreground = 'blue'
          background = 'transparent'
          template = '{{ .Path }}'

          [blocks.segments.properties]
            style = 'full'

        [[blocks.segments]]
          type = 'git'
          style = 'plain'
          foreground = '#6c6c6c'
          background = 'transparent'
          template = " {{ .HEAD }}{{\n  if or (.Working.Changed) (.Staging.Changed)\n}}*{{ end }} <cyan>{{\n  if gt .Behind 0\n}}{{ .Behind }}⇣{{ end }}{{\n  if gt .Ahead 0\n}}{{ .Ahead }}⇡{{ end }}</>"

          [blocks.segments.properties]
            branch_icon = '''
            commit_icon = '@'
            fetch_status = true

      [[blocks]]
        type = 'rprompt'
        overflow = 'hidden'

        [[blocks.segments]]
          type = 'executiontime'
          style = 'plain'
          foreground = 'yellow'
          background = 'transparent'
          template = '{{ .FormattedMs }}'

          [blocks.segments.properties]
            threshold = 2000.0

        [[blocks.segments]]
          type = 'lastfm'
          style = 'plain'
          foreground = 'green'
          background = 'transparent'
          template = ' {{ .Icon }}{{ if ne .Status "stopped" }}{{ .Full }}{{ end }} '

          [blocks.segments.properties]
            api_key = '${config.sops.placeholder.lastfm_auth}'
            cache_timeout = 1.0
            http_timeout = 10000.0
            username = 'TheColorman'

        [[blocks.segments]]
          type = 'battery'
          style = 'plain'
          foreground_templates = ['{{ if ge .Percentage 50 }}green{{ end }}', '{{ if ge .Percentage 20 }}yellow{{ end }}', '{{ if lt .Percentage 20 }}red{{ end }}']
          background = 'transparent'
          template = "{{\n            if eq .Percentage 80 }}󰁹{{\n            else if eq \"Discharging\" .State.String }}{{\n                   if ge .Percentage 53 }}󱊣{{\n              else if ge .Percentage 26 }}󱊢{{\n              else if ge .Percentage 10 }}󱊡{{\n              else                      }}󰂎{{ end }} {{ .Percentage }}%{{\n            else }}󰂄 {{ .Percentage }}%{{ end }} "

      [[blocks]]
        type = 'prompt'
        alignment = 'left'
        newline = true

        [[blocks.segments]]
          type = 'text'
          style = 'plain'
          foreground_templates = ['{{ if gt .Code 0 }}red{{ end }}', '{{ if eq .Code 0 }}magenta{{ end }}']
          background = 'transparent'
          template = '❯'

      [transient_prompt]
        foreground_templates = ['{{ if gt .Code 0 }}red{{ end }}', '{{ if eq .Code 0 }}magenta{{ end }}']
        background = 'transparent'
        template = '❯ '

      [secondary_prompt]
        foreground = 'magenta'
        background = 'transparent'
        template = '❯❯ '
    '';
  };
}
