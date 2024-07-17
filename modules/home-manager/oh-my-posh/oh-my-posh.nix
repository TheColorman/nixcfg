# Inspired by Dreams of Code: https://www.youtube.com/watch?v=9U8LCjuQzdc
# @TODO: Use stylix colors here instead of strings

{ pkgs, ... }: {
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  enableFishIntegration = false;
  enableNushellIntegration = false;
  settings = {
    version = 2;
    final_space = true;
    console_title_template = "{{ .Shell }} in {{ .Foldir }}";
    blocks = [ {
      type = "prompt";
      alignment = "left";
      newline = true;
      segments = [ {
        type = "os";
        style = "plain";
        background = "transparent";
        template = "{{ .Icon }}  ";
      } {
        type = "path";
        style = "plain";
        background = "transparent";
        foreground = "blue";
        template = "{{ .Path }}";
        properties = { style = "full"; };
      } {
        type = "git";
        style = "plain";
        background = "transparent";
        foreground = "#6c6c6c";
        template = ''
           {{ .HEAD }}{{
            if or (.Working.Changed) (.Staging.Changed)
          }}*{{ end }} <cyan>{{
            if gt .Behind 0
          }}{{ .Behind }}⇣{{ end }}{{
            if gt .Ahead 0
          }}{{ .Ahead }}⇡{{ end }}</>'';
        properties = {
          branch_icon = "";
          commit_icon = "@";
          fetch_status = true;
        };
      } ];
    } {
      type = "rprompt";
      overflow = "hidden";
      segments = [ {
        type = "executiontime";
        style = "plain";
        background = "transparent";
        foreground = "yellow";
        template = "{{ .FormattedMs }}";
        properties = {
          threshold = 2000;
        };
      } {
        type = "lastfm";
        style = "plain";
        background = "transparent";
        foreground = "green";
        template = " {{ .Icon }}{{ if ne .Status \"stopped\" }}{{ .Full }}{{ end }} ";
        properties = {
          api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../../secrets/lastfm);
          username = "TheColorman";
          http_timeout = 10000;
          cache_timeout = 1;
        };
      } {
        type = "battery";
        style = "plain";
        background = "transparent";
        foreground_templates = [
          "{{ if ge .Percentage 50 }}green{{ end }}"
          "{{ if ge .Percentage 20 }}yellow{{ end }}"
          "{{ if lt .Percentage 20 }}red{{ end }}"
        ];
        # I'm using 80% as de-facto "fully charged" since I have a battery limiter.
        template = ''{{
            if eq .Percentage 80 }}󰁹{{
            else if eq "Discharging" .State.String }}{{
                   if ge .Percentage 53 }}󱊣{{
              else if ge .Percentage 26 }}󱊢{{
              else if ge .Percentage 10 }}󱊡{{
              else                      }}󰂎{{ end }} {{ .Percentage }}%{{
            else }}󰂄 {{ .Percentage }}%{{ end }} '';
      } ];
    } {
      type = "prompt";
      alignment = "left";
      newline = true;
      segments = [ {
        type = "text";
        style = "plain";
        background = "transparent";
        foreground_templates = [
          "{{ if gt .Code 0 }}red{{ end }}"
          "{{ if eq .Code 0 }}magenta{{ end }}"
        ];
        template = "❯";
      } ];
    } ];
    transient_prompt = {
      background = "transparent";
      foreground_templates = [
        "{{ if gt .Code 0 }}red{{ end }}"
        "{{ if eq .Code 0 }}magenta{{ end }}"
      ];
      template = "❯ ";
    };
    secondary_prompt = {
        background = "transparent";
        foreground = "magenta";
        template = "❯❯ ";
    };
  };
}
