{ inputs, lib, ... }:
{
  flake.nixosModules.services-caelestia =
    { config, ... }:
    let
      inherit (config.my) username;
    in
    {
      options.my.markers.caelestia.enable = lib.mkEnableOption "Caelestia shell";

      config = {
        my = {
          markers.caelestia.enable = true;
          autostart = [
            "caelestia resizer -d"
            "caelestia shell -d"
          ];
        };

        home-manager.users."${username}" = {
          imports = [ inputs.caelestia.homeManagerModules.default ];

          programs.caelestia = {
            enable = true;
            systemd.enable = false; # Managed by UWSM
            cli.enable = true;

            settings = {
              appearance.transparency = {
                enabled = true;
                base = 0.85;
                layers = 0.4;
              };

              background = {
                enabled = true;
                desktopClock = {
                  enabled = true;
                  background.enabled = false;
                  invertColors = false;
                  position = "bottom-right";
                  shadow.enabled = true;
                };
                visualiser = {
                  enabled = true;
                  autoHide = false;
                  blur = true;
                };
              };

              bar = {
                clock.showIcon = false;
                persistent = false;
                popouts.activeWindow = false;
                status = {
                  showAudio = true;
                  showBattery = lib.mkDefault false;
                  showKbLayout = false;
                  showLockStatus = true;
                  showMicrophone = false;
                  showNetwork = false;
                  showWifi = lib.mkDefault false;
                };
              };

              general.apps = {
                explorer = [
                  "kitty"
                  "yazi"
                ];
                terminal = [ "kitty" ];
              };

              launcher.enableDangerousActions = true;
              services = {

                defaultPlayer = "YouTube Music";
                playerAliases = [
                  {
                    from = "com.github.th_ch.youtube_music";
                    to = "YouTube Music";
                  }
                ];
              };

              utilities = {
                toasts.nowPlaying = true;
                vpn.provider = lib.optional config.services.tailscale.enable {
                  enabled = true;
                  displayName = "Tailscale";
                  interface = "tailscale0";
                  name = "tailscale";
                };
              };
            };
          };

          wayland.windowManager.hyprland.settings = {
            # exec = [
            #   "hyprctl dispatch submap global"
            # ];
            # submap = "global";

            # See https://github.com/caelestia-dots/caelestia/blob/main/hypr/hyprland/keybinds.conf#L1-L39
            bind =
              let
                mkBindR = key: lua: rules: {
                  _args = [
                    key
                    (lib.generators.mkLuaInline lua)
                    rules
                  ];
                };
                mkBind = key: lua: mkBindR key lua { };
                mkBindCmdR =
                  key: cmd: rules:
                  mkBindR key "hl.dsp.exec_cmd(${builtins.toJSON cmd})" rules;
                mkBindCmd = key: cmd: mkBindCmdR key cmd { };
              in
              [
                # Launcher
                # FIXME: Can't get the `caelestia:launcher` dispatch to work
                (mkBindCmd "ALT + SPACE" "caelestia shell drawers toggle launcher")

                # Misc
                (mkBind "SUPER + L" ''hl.dsp.global("caelestia:lock")'')
                (mkBindCmd "SUPER + N" "caelestia shell drawers toggle sidebar")

                # Utilities
                #   Capture region (freeze)
                (mkBind "SUPER + SHIFT + S" ''hl.dsp.global("caelestia:screenshotFreeze")'')
                #   Capture region
                (mkBind "SUPER + SHIFT + ALT + S" ''hl.dsp.global("caelestia:screenshot")'')
                #   Record screen with sound
                (mkBindCmd "SUPER + ALT + R" "caelestia record -s")
                #   Record screen
                (mkBindCmd "CTRL + ALT + R" "caelestia record")
                #   Record region
                (mkBindCmd "SUPER + SHIFT + ALT + R" "caelestia record -r")

                # Clipboard and emoji picker
                (mkBindCmd "SUPER + V" "pkill fuzzel || caelestia clipboard")
                (mkBindCmd "SUPER + ALT + V" "pkill fuzzel || caelestia clipboard -d")
                (mkBindCmd "SUPER + Period" "pkill fuzzel || caelestia emoji -p")
                #   Alternate paste
                (mkBindCmdR "CTRL + SHIFT + ALT + V"
                  ''sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"''
                  { locked = true; }
                )

                # Brightness
                (mkBindR "XF86MonBrightnessUp" ''hl.dsp.global("caelestia:brightnessUp")'' { locked = true; })
                (mkBindR "XF86MonBrightnessDown" ''hl.dsp.global("caelestia:brightnessDown")'' {
                  locked = true;
                })

                # Media
                (mkBindR "CTRL + SUPER + Space" ''hl.dsp.global("caelestia:mediaToggle")'' { locked = true; })
                (mkBindR "XF86AudioPlay" ''hl.dsp.global("caelestia:mediaToggle")'' { locked = true; })
                (mkBindR "XF86AudioPause" ''hl.dsp.global("caelestia:mediaToggle")'' { locked = true; })
                (mkBindR "CTRL + SUPER + Equal" ''hl.dsp.global("caelestia:mediaNext")'' { locked = true; })
                (mkBindR "XF86AudioNext" ''hl.dsp.global("caelestia:mediaNext")'' { locked = true; })
                (mkBindR "CTRL + SUPER + Minus" ''hl.dsp.global("caelestia:mediaPrev")'' { locked = true; })
                (mkBindR "XF86AudioPrev" ''hl.dsp.global("caelestia:mediaPrev")'' { locked = true; })
                (mkBindR "XF86AudioStop" ''hl.dsp.global("caelestia:mediaStop")'' { locked = true; })

                # Utilities
                #   Full screen capture > clipboard
                (mkBindCmdR "Print" "caelestia screenshot" { locked = true; })
              ];
          };

          services.cliphist = {
            enable = true;
            allowImages = true;
          };
        };
      };
    };
}
