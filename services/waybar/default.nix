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
      enableInspect = true;
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        reload_style_on_change = true;
        modules-left = [
          "custom/notification"
          "clock"
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
        # "custom/notification" = {
        #   escape = true;
        #   format = "";
        #   on-click = "swaync-client -t -sw";
        #   tooltip = false;
        # };
        clock = {
          actions = {
            on-click = "shift_up";
            on-click-right = "shift_down";
          };

          calendar.format.today = "<span color='#fAfBfC'><b>{}</b></span>";
          format = "{:%H:%M} ";
          tooltip-format = "<tt>{calendar}</tt>";
        };
        tray = {
          icon-size = 14;
          spacing = 10;
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
        cpu = {
          format = "󰻠";
          tooltip = true;
        };
        memory.format = "";
        temperature = {
          critical-threshold = 80;
          format = "";
        };
        bluetooth = {
          format-alt = "{device_alias} 󰂯";
          format-connected-battery = "{device_battery_percentage}% 󰂯";
          format-disabled = "󰂲";
          format-off = "BT-off";
          format-on = "󰂯";
          on-click-right = "${pkgs.blueman}/bin/blueman-manager";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
        };
        network = {
          format-disconnected = "";
          format-ethernet = "";
          format-wifi = "";
          on-click = "kitty nmtui";
          tooltip-format-disconnected = "Error";
          tooltip-format-ethernet = "{ifname} 🖧 ";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
        };
        battery = {
          format = "{capacity}% {icon}";
          format-alt = "{time} {icon}";
          format-charging = "{capacity}% 󰂄";
          format-icons = [
            "󰁻"
            "󰁼"
            "󰁾"
            "󰂀"
            "󰂂"
            "󰁹"
          ];
          format-plugged = "{capacity}% 󰂄 ";
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

      #network,
      #network.disconnected {
        padding: 0 10px 0 5px;
      }
      #bluetooth {
        margin-left: 5px;
      }
    '';
  };
}
