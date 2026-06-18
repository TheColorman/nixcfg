{ self, ... }:
{
  flake.nixosModules.system-desktop-hyprland-hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.meta) getExe getExe';
      inherit (lib.options) mkOption;
      inherit (lib.types)
        either
        str
        listOf
        attrsOf
        anything
        ;
      inherit (config.my) username;
    in
    {
      imports = with self.nixosModules; [ system-desktop-wayland ];

      options.my.hyprland = {
        extraMonitorSettings = mkOption {
          type = listOf (either (attrsOf anything) str);
          default = [ ];
          description = "Additional monitors to configure";
        };
      };

      config =
        let
          hyprlandConfig =
            let
              term = getExe pkgs.kitty;
              fileManager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
              uwsm = "uwsm app -- ";
            in
            {
              # === Autostart ===
              on._args = [
                "hyprland.start"
                (lib.generators.mkLuaInline ''
                  function()
                    ${
                      config.my.autostart
                      |> map (cmd: builtins.toJSON "uwsm app -- ${cmd}")
                      |> lib.concatMapStringsSep "\n" (cmd: "hl.exec_cmd(${cmd})")
                    }
                  end
                '')
              ];

              config = {
                # === Look and feel ===
                general = {
                  gaps_in = 5;
                  gaps_out = 10;

                  border_size = 2;

                  resize_on_border = false;

                  allow_tearing = false;

                  layout = "dwindle";
                };

                # Fixes issues where the mouse is not detecting at the edges of the
                # screen, breaking e.g. the mouse gestures in Caelestia
                cursor.hotspot_padding = 1;

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
                    passes = 2;
                    new_optimizations = true;

                    vibrancy = 0.1696;
                  };
                };

                dwindle.preserve_split = true;

                # === Input ===
                input = {
                  kb_layout = "us,us";
                  kb_variant = ",colemak_dh";
                  resolve_binds_by_sym = true;
                  follow_mouse = 1;
                  touchpad = {
                    natural_scroll = true;
                    scroll_factor = .6;
                  };
                  repeat_rate = 55;
                  repeat_delay = 225;
                };

              };

              animation =
                let
                  mkAnimSt = leaf: speed: bezier: style: {
                    inherit
                      leaf
                      speed
                      bezier
                      style
                      ;
                    enabled = true;
                  };
                  mkAnim = leaf: speed: bezier: {
                    inherit leaf speed bezier;
                    enabled = true;
                  };
                in
                [
                  (mkAnim "global" 10 "default")
                  (mkAnim "border" 5.39 "easeOutQuint")
                  (mkAnim "windows" 4.79 "easeOutQuint")
                  (mkAnimSt "windowsIn" 4.1 "easeOutQuint" "popin 87%")
                  (mkAnimSt "windowsOut" 1.49 "linear" "popin 87%")
                  (mkAnim "fadeIn" 1.73 "almostLinear")
                  (mkAnim "fadeOut" 1.46 "almostLinear")
                  (mkAnim "fade" 3.03 "quick")
                  (mkAnim "layers" 3.81 "easeOutQuint")
                  (mkAnimSt "layersIn" 4 "easeOutQuint" "fade")
                  (mkAnimSt "layersOut" 1.5 "linear" "fade")
                  (mkAnim "fadeLayersIn" 1.79 "almostLinear")
                  (mkAnim "fadeLayersOut" 1.39 "almostLinear")
                  (mkAnimSt "workspaces" 1.94 "almostLinear" "fade")
                  (mkAnimSt "workspacesIn" 1.21 "almostLinear" "fade")
                  (mkAnimSt "workspacesOut" 1.94 "almostLinear" "fade")
                ];

              curve =
                let
                  mkBezier = name: x0: y0: x1: y1: {
                    _args = [
                      name
                      {
                        type = "bezier";
                        points = [
                          [
                            x0
                            y0
                          ]
                          [
                            x1
                            y1
                          ]
                        ];
                      }
                    ];
                  };
                in
                [
                  (mkBezier "easeOutQuint" 0.23 1 0.32 1)
                  (mkBezier "easeInOutCubic" 0.65 0.05 0.36 1)
                  (mkBezier "linear" 0 0 1 1)
                  (mkBezier "almostLinear" 0.5 0.5 0.75 1)
                  (mkBezier "quick" 0.15 0 0.1 1)
                ];

              bind =
                let
                  mkBindR = key: lua: rules: {
                    _args = [
                      key
                      (lib.generators.mkLuaInline lua)
                      rules
                    ];
                  };
                  mkBind = key: lua: {
                    _args = [
                      key
                      (lib.generators.mkLuaInline lua)
                    ];
                  };
                  mkBindCmd = key: cmd: mkBind key "hl.dsp.exec_cmd(${builtins.toJSON cmd})";
                  mkBindCmdR =
                    key: cmd: execRules:
                    mkBind key "hl.dsp.exec_cmd(${builtins.toJSON cmd}, ${lib.generators.toLua { } execRules})";

                  # EXEs
                  hyprpicker = getExe pkgs.hyprpicker;
                  vesktop = getExe pkgs.vesktop;
                  browser = getExe (pkgs.zen-browser or pkgs.ungoogled-chromium);
                  music = getExe pkgs.pear-desktop;
                  pano = getExe pkgs.pano-scrobbler;
                  wpctl = getExe' pkgs.wireplumber "wpctl";
                in
                [
                  (mkBindCmd "SUPER + T" "${uwsm} ${term}")
                  (mkBindCmdR "SUPER + ALT + T" "${uwsm} ${term}" {
                    float = true;
                    size = "50%";
                  })
                  (mkBind "SUPER + Q" "hl.dsp.window.close()")
                  (mkBindCmd "SUPER + M" "uwsm stop")
                  (mkBindCmd "SUPER + E" "${uwsm} ${fileManager}")
                  (mkBindCmdR "SUPER + ALT + E" "${uwsm} ${fileManager}" {
                    float = true;
                    size = "50%";
                  })
                  (mkBind "SUPER + D" "hl.dsp.window.float({ action = \"toggle\" })")
                  (mkBind "SUPER + SHIFT + D" "hl.dsp.window.pin()")
                  (mkBind "SUPER + F" "hl.dsp.window.fullscreen({ action = \"toggle\" })")
                  (mkBindCmd "SUPER + SHIFT + C" "${uwsm} ${hyprpicker} --autocopy")

                  # Applications
                  (mkBindCmd "SUPER + SHIFT + D" "${uwsm} ${vesktop}")
                  (mkBindCmd "SUPER + SHIFT + B" "${uwsm} ${browser}")
                  (mkBindCmd "SUPER + SHIFT + M" "${uwsm} ${music} & ${uwsm} ${pano}")

                  # Move focus with mod + arrow keys
                  (mkBind "SUPER + left" "hl.dsp.focus({ direction = \"l\" })")
                  (mkBind "SUPER + right" "hl.dsp.focus({ direction = \"r\" })")
                  (mkBind "SUPER + up" "hl.dsp.focus({ direction = \"u\" })")
                  (mkBind "SUPER + down" "hl.dsp.focus({ direction = \"d\" })")

                  # Switch workspaces with mod + [0-9]
                  (mkBind "SUPER + 1" "hl.dsp.focus({ workspace = 1 })")
                  (mkBind "SUPER + 2" "hl.dsp.focus({ workspace = 2 })")
                  (mkBind "SUPER + 3" "hl.dsp.focus({ workspace = 3 })")
                  (mkBind "SUPER + 4" "hl.dsp.focus({ workspace = 4 })")
                  (mkBind "SUPER + 5" "hl.dsp.focus({ workspace = 5 })")
                  (mkBind "SUPER + 6" "hl.dsp.focus({ workspace = 6 })")
                  (mkBind "SUPER + 7" "hl.dsp.focus({ workspace = 7 })")
                  (mkBind "SUPER + 8" "hl.dsp.focus({ workspace = 8 })")
                  (mkBind "SUPER + 9" "hl.dsp.focus({ workspace = 9 })")
                  (mkBind "SUPER + 0" "hl.dsp.focus({ workspace = 10 })")

                  # Move active window to a workspace with mod + SHIFT + [0-9]
                  (mkBind "SUPER + SHIFT + 1" "hl.dsp.window.move({ workspace = 1 })")
                  (mkBind "SUPER + SHIFT + 2" "hl.dsp.window.move({ workspace = 2 })")
                  (mkBind "SUPER + SHIFT + 3" "hl.dsp.window.move({ workspace = 3 })")
                  (mkBind "SUPER + SHIFT + 4" "hl.dsp.window.move({ workspace = 4 })")
                  (mkBind "SUPER + SHIFT + 5" "hl.dsp.window.move({ workspace = 5 })")
                  (mkBind "SUPER + SHIFT + 6" "hl.dsp.window.move({ workspace = 6 })")
                  (mkBind "SUPER + SHIFT + 7" "hl.dsp.window.move({ workspace = 7 })")
                  (mkBind "SUPER + SHIFT + 8" "hl.dsp.window.move({ workspace = 8 })")
                  (mkBind "SUPER + SHIFT + 9" "hl.dsp.window.move({ workspace = 9 })")
                  (mkBind "SUPER + SHIFT + 0" "hl.dsp.window.move({ workspace = 10 })")

                  # Special workspace (scratchpad)
                  (mkBind "SUPER + R" "hl.dsp.workspace.toggle_special(\"magic\")")
                  (mkBind "SUPER + SHIFT + R" "hl.dsp.window.move({ workspace = \"special:magic\" })")

                  # Scroll through existing workspaces with mod + scroll
                  (mkBind "SUPER + mouse_down" "hl.dsp.focus({ workspace = \"e+1\" })")
                  (mkBind "SUPER + mouse_up" "hl.dsp.focus({ workspace = \"e-1\" })")

                  # Move workspaces between monitors
                  (mkBind "CTRL + ALT + SUPER + SHIFT + comma" "hl.dsp.workspace.move({ monitor = \"l\" })")
                  (mkBind "CTRL + ALT + SUPER + SHIFT + period" "hl.dsp.workspace.move({ monitor = \"r\" })")

                  # Keyboard layout
                  (mkBindCmd "Control_R + Shift_R + Space" "hyprctl switchxkblayout kanata next")

                  # Move/resize windows with mod + LMG/RMG and dragging
                  (mkBindR "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
                  (mkBindR "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

                  # Multimedia keys
                  (mkBindCmd "XF86AudioRaiseVolume" "${uwsm} ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
                  (mkBindCmd "XF86AudioLowerVolume" "${uwsm} ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-")
                  (mkBindCmd "XF86AudioMute" "${uwsm} ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle")
                  (mkBindCmd "XF86AudioMicMute" "${uwsm} ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle")

                ];

              window_rule = [
                {
                  name = "no-auto-maximize";
                  match.class = ".*";
                  suppress_event = "maximize";
                }
                {
                  name = "no-focus-floating-xwayland";
                  match = {
                    class = "^$";
                    title = "^$";
                    xwayland = true;
                    float = true;
                    fullscreen = false;
                    pin = false;
                  };
                  no_focus = true;
                }
                {
                  name = "transparency";
                  match.class =
                    [
                      "vesktop"
                      "com.github.th_ch.youtube_music"
                      "zen-twilight"
                      "steam"
                    ]
                    |> builtins.concatStringsSep "|";
                  opacity = "0.9 0.8";
                }
              ];

              monitor = [
                {
                  output = "";
                  mode = "preferred";
                  position = "auto";
                  scale = "auto";
                }
              ];

              misc.initial_workspace_tracking = 1;
            };
        in
        {
          # ==== System ====
          programs.hyprland = {
            enable = true;
            withUWSM = true; # https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#uwsm
          };

          # See https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
          environment.variables."NIXOS_OZONE_WL" = 1;

          # ==== User ====
          home-manager.users."${username}" = {
            wayland.windowManager.hyprland = {
              enable = true;
              systemd.enable = false; # Conflicts with uwsm
              configType = "lua";
              settings = hyprlandConfig;
            };
            xdg.configFile = {
              "uwsm/env".text = ''
                export XCURSOR_SIZE=24
              '';
              "uwsm/env-hyprland".text = ''
                export HYPRCURSOR_SIZE=24
              '';
            };
            services = {
              hyprpaper.enable = true;
              hyprpolkitagent.enable = true;
              cliphist = {
                enable = true;
                allowImages = true;
              };
            };
          };
        };
    };
}
