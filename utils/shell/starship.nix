{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.my) username;
  inherit (lib.modules) mkIf;
  inherit (lib) getExe;
  fishEnabled = config.home-manager.users."${username}".programs.fish.enable;
in {
  home-manager.users."${username}" = {
    programs.starship = {
      enable = true;
      enableInteractive = true;
      # enableTransience = true;
      settings = {
        format = ''
          $os$hostname$localip$singularity$kubernetes$directory''${custom.jujutsu}$all $line_break $jobs$status$container$netns$shell$shlvl$character
        '';
        right_format = ''
          ''${custom.lastfm}$time$battery
        '';
        # Modules
        battery.display = [
          {
            threshold = 10;
            style = "bold red";
          }
          {
            threshold = 30;
            style = "bold yellow";
            discharging_symbol = "󰁼 ";
          }
          {
            threshold = 50;
            style = "bold green";
            discharging_symbol = "󰁾 ";
          }
          {
            threshold = 100;
            style = "bold green";
            discharging_symbol = "󰂂 ";
          }
        ];
        cmd_duration.format = "[󰔛 $duration]($style) ";
        directory.truncation_length = 0;
        nix_shell = {
          format = "in  🐚 ";
        };
        git_branch.disabled = true; # I'm branchless
        os = {
          disabled = false;
          symbols.NixOS = "  ";
          style = "bold blue";
        };
        shlvl = {
          disabled = false;
          symbol = "";
          format = "[$shlvl$symbol]($style) ";
        };
        sudo.disabled = false;
        time = {
          disabled = false;
          format = "󰥔 [$time]($style) ";
          time_format = "%R";
        };
        custom.jujutsu = {
          command = ''
            jj log \
              --color always \
              --no-pager \
              -r @ \
              --no-graph \
              -T 'concat(
                format_short_change_id_with_hidden_and_divergent_info(self),
                surround(" ", "", local_bookmarks.join(" ")),
                surround(
                  " ",
                  "",
                  parents.map(|parent| "~" ++ parent.local_bookmarks().join(" ")).join(" "),
                ),
              )'
          '';
          detect_folders = [".jj"];
          format = "$output ";
        };
        custom.lastfm = {
          command = ''
            ${getExe pkgs.bkt} --ttl 10s -- ${getExe pkgs.xh} \
              'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=TheColorman&api_key=32a6e8eeeeb0129fcffbc9db80410589&format=json&limit=1' \
                | jq ".recenttracks.track[0]" \
                | jq -r 'if .["@attr"].nowplaying == "true" then "\(.artist["#text"]) - \(.name)" else "" end'
          '';
          when = true;
          style = "250";
          symbol = "󰎇 ";
          ignore_timeout = true;
        };
      };
      # This adds starship to the interactiveShellInit section which is an
      # issue as I rely on the starship prompt being available to background
      # processes so that fish-async-prompt can grab it.
      enableFishIntegration = false;
    };
    programs.fish = mkIf fishEnabled {
      functions."transient_prompt_func" = "starship module character";

      # See https://github.com/nix-community/home-manager/blob/d5f1f641b289553927b3801580598d200a501863/modules/programs/starship.nix#L109
      # Included here instead of using the built in integration so that I can
      # activate starship even non-interactively
      shellInit = let
        starshipCmd = "${config.home-manager.users."${username}".home.profileDirectory}/bin/starship";
      in ''
        eval (${starshipCmd} init fish)
      '';
    };
  };
}
