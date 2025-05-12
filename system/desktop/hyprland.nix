{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) listOf str;
  inherit (config.my) username;

  cfg = config.my.hyprland;
in {
  options.my.hyprland = {
    extraMonitorSettings = mkOption {
      type = listOf str;
      default = [];
      description = "Additional monitors to configure";
    };
  };

  config = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.variables = {
      NIXOS_OZONE_WL = 1;
    };

    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        hyprpicker
        hyprshot
        walker
        cliphist
        brightnessctl
      ];
      services.hyprpaper.enable = true;
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false; # Conflicts with uwsm
        settings = let
          term = "kitty";
          fileManager = "dolphin";
          menu = "walker";
          mod = "SUPER";
        in {
          # === Monitors ===
          monitor = [",preferred,auto,auto"] ++ cfg.extraMonitorSettings;

          # === Autostart ===
          exec-once = [
            "waybar"
            "wl-paste --watch cliphist --max-items 25 store"
            "safeeyes"
          ];

          # === Environment variables ===
          env = [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          # === Look and feel ===
          general = {
            gaps_in = 5;
            gaps_out = 20;

            border_size = 2;

            resize_on_border = false;

            allow_tearing = false;

            layout = "dwindle";
          };

          decoration = {
            rounding = 10;
            rounding_power = 2;

            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
            };

            # https://wiki.hyprland.org/Configuring/Variables/#blur
            blur = {
              enabled = true;
              size = 3;
              passes = 1;

              vibrancy = 0.1696;
            };
          };

          animations = {
            enabled = true;
            bezier = [
              "easeOutQuint,0.23,1,0.32,1"
              "easeInOutCubic,0.65,0.05,0.36,1"
              "linear,0,0,1,1"
              "almostLinear,0.5,0.5,0.75,1.0"
              "quick,0.15,0,0.1,1"
            ];

            animation = [
              "global, 1, 10, default"
              "border, 1, 5.39, easeOutQuint"
              "windows, 1, 4.79, easeOutQuint"
              "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
              "windowsOut, 1, 1.49, linear, popin 87%"
              "fadeIn, 1, 1.73, almostLinear"
              "fadeOut, 1, 1.46, almostLinear"
              "fade, 1, 3.03, quick"
              "layers, 1, 3.81, easeOutQuint"
              "layersIn, 1, 4, easeOutQuint, fade"
              "layersOut, 1, 1.5, linear, fade"
              "fadeLayersIn, 1, 1.79, almostLinear"
              "fadeLayersOut, 1, 1.39, almostLinear"
              "workspaces, 1, 1.94, almostLinear, fade"
              "workspacesIn, 1, 1.21, almostLinear, fade"
              "workspacesOut, 1, 1.94, almostLinear, fade"
            ];
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          # === Input ===
          input = {
            kb_layout = "us";
            follow_mouse = 1;
            touchpad.natural_scroll = true;
            repeat_rate = 55;
            repeat_delay = 225;
          };

          gestures.workspace_swipe = true;

          bind = [
            "${mod}, T, exec, ${term}"
            "${mod} ALT, T, exec, [float; size 50%] ${term}"
            "${mod}, Q, killactive,"
            "${mod}, M, exit,"
            "${mod}, E, exec, ${fileManager}"
            "${mod} ALT, E, exec, [float; size 50%] ${fileManager}"
            "${mod}, D, togglefloating,"
            "${mod}, F, fullscreen"
            "${mod} SHIFT, F, fullscreenstate, -1, 2"
            "ALT, SPACE, exec, ${menu}"
            "${mod}, P, pseudo,"
            "${mod}, J, togglesplit,"
            "${mod} SHIFT, S, exec, hyprshot --clipboard-only -m region"
            "${mod} SHIFT, C, exec, hyprpicker --autocopy"

            # Applications
            "${mod} SHIFT, D, exec, vesktop --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto"
            "${mod} SHIFT, B, exec, firefox"

            # Move focus with mod + arrow keys
            "${mod}, left, movefocus, l"
            "${mod}, right, movefocus, r"
            "${mod}, up, movefocus, u"
            "${mod}, down, movefocus, d"

            # Switch workspaces with mod + [0-9]
            "${mod}, 1, workspace, 1"
            "${mod}, 2, workspace, 2"
            "${mod}, 3, workspace, 3"
            "${mod}, 4, workspace, 4"
            "${mod}, 5, workspace, 5"
            "${mod}, 6, workspace, 6"
            "${mod}, 7, workspace, 7"
            "${mod}, 8, workspace, 8"
            "${mod}, 9, workspace, 9"
            "${mod}, 0, workspace, 10"

            # Move active window to a workspace with mod + SHIFT + [0-9]
            "${mod} SHIFT, 1, movetoworkspace, 1"
            "${mod} SHIFT, 2, movetoworkspace, 2"
            "${mod} SHIFT, 3, movetoworkspace, 3"
            "${mod} SHIFT, 4, movetoworkspace, 4"
            "${mod} SHIFT, 5, movetoworkspace, 5"
            "${mod} SHIFT, 6, movetoworkspace, 6"
            "${mod} SHIFT, 7, movetoworkspace, 7"
            "${mod} SHIFT, 8, movetoworkspace, 8"
            "${mod} SHIFT, 9, movetoworkspace, 9"

            # Example special workspace (scratchpad)
            "${mod}, R, togglespecialworkspace, magic"
            "${mod} SHIFT, R, movetoworkspace, special:magic"

            # Scroll through existing workspaces with mod + scroll
            "${mod}, mouse_down, workspace, e+1"
            "${mod}, mouse_up, workspace, e-1"
          ];

          bindm = [
            # Move/resize windows with mod + LMG/RMG and dragging
            "${mod}, mouse:272, movewindow"
            "${mod}, mouse:273, resizewindow"
          ];

          bindel = [
            # Laptop multimedia keys for volume and LCD brightness
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%-"
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
            ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
          ];

          bindl = [
            # Requires playerctl
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPause, exec, playerctl play-pause"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
          ];

          windowrule = [
            "suppressevent maximize, class:.*"
            "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          ];
        };
      };
    };
  };
}
