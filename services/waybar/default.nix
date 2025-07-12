{
  config,
  pkgs,
  ...
}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    settings = with config.lib.stylix.colors; {
      mainBar = {
        layer = "top";
        position = "top";
        reload_style_on_change = true;
        modules-left = [
          "clock"
          "hyprland/language"
          "tray"
        ];
        modules-center = ["hyprland/workspaces"];
        modules-right = [
          "cpu"
          "memory"
          "temperature"
          "bluetooth"
          "network"
          "battery"
        ];
        clock = {
          actions.on-click-right = "mode";

          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "left";
            on-scroll = 1;
            format = {
              months = "<span color='#${base05}'><b>{}</b></span>";
              days = "<span color='#${base0C}'><b>{}</b></span>";
              weeks = "<span color='#${base08}'><b>{:%V}</b></span>";
              weekdays = "<span color='#${base04}'><b>{}</b></span>";
              today = "<span color='#${base07}'><b><u>{}</u></b></span>";
            };
            locale = "en_AU.UTF-8";
          };
          format = "{:%H:%M} ";
          tooltip-format = "<tt>{calendar}</tt>";
        };
        tray = {
          icon-size = 14;
          spacing = 10;
          # icons = {
          #   nm-applet = "bluetooth";
          # };
        };
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
            empty = "";
          };
          persistent-workspaces."*" = [
            1
            2
            3
            4
            5
          ];
        };
        # "backlight/slider" = {};
        cpu = {
          format = " ";
          tooltip = true;
        };
        memory.format = " ";
        temperature = {
          critical-threshold = 80;
          format = " ";
        };
        bluetooth = {
          format-alt = "{device_alias} 󰂱 ";
          format-connected-battery = "{device_battery_percentage}% 󰂱 ";
          format-disabled = "󰂲 ";
          format-off = "󰂲 ";
          format-on = "󰂯";
          on-click-right = "${pkgs.blueman}/bin/blueman-manager";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
        };
        network = {
          format-disconnected = " ";
          format-ethernet = " ";
          format-wifi = " ";
          on-click = "kitty nmtui";
          tooltip-format-disconnected = "No internet";
          tooltip-format-ethernet = "{ifname} 󰈀 ";
          tooltip-format-wifi = "{essid} ({signalStrength}%)  ";
        };
        battery = {
          format = "{capacity}% {icon}";
          format-alt = "{time} {icon}";
          format-charging = "{capacity}% 󰂄 ";
          format-icons = [
            "󰁻 "
            "󰁼 "
            "󰁾 "
            "󰂀 "
            "󰂂 "
            "󰁹 "
          ];
          format-plugged = "{capacity}% 󰂄  ";
          interval = 30;
          states = {
            critical = 20;
            good = 95;
            warning = 30;
          };
        };
      };
    };
    style = ''
      window#waybar {
        all: unset;
      }

      .modules-left {
        padding: 7px;
        margin: 10px 0px 3px 10px;
        border-radius: 10px;
        background: alpha(@base01, .6);
        box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
      }

      .modules-center {
        padding: 7px;
        margin: 10px 0px 3px 10px;
        border-radius: 10px;
        background: alpha(@base01, .6);
        box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
      }

      .modules-right {
        padding: 7px;
        margin: 10px 10px 3px 10px;
        border-radius: 10px;
        background: alpha(@base01, .6);
        box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
      }

      tooltip {
        border-color: @base0D;
        background: @base01;
        color: @base04;
      }

      .modules-center #workspaces button.focused,
      .modules-center #workspaces button.active {
        border: none;

      }
      #workspaces button {
        margin: 0;
        padding: 0 5px;
      }
      #workspaces button.focused,
      #workspaces button.active {
        /* why the hell is this necessary */
        margin-top: -2px;
      }

      #tray {
        margin-left: 6px;
      }
    '';
  };
}
