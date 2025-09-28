{
  config,
  inputs,
  ...
}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}" = {
    imports = [inputs.caelestia.homeManagerModules.default];

    programs.caelestia = {
      enable = true;
      systemd.enable = false; # Managed by UWSM
      cli.enable = true;
    };

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "uwsm app -- caelestia resizer -d"
        "uwsm app -- caelestia shell -d"
      ];

      # exec = [
      #   "hyprctl dispatch submap global"
      # ];
      # submap = "global";

      # See https://github.com/caelestia-dots/caelestia/blob/main/hypr/hyprland/keybinds.conf#L1-L39
      bindin = [
        # Launcher
        # "Super, catchall, global, caelestia:launcherInterrupt"
        "Super, mouse:272, global, caelestia:launcherInterrupt"
        "Super, mouse:273, global, caelestia:launcherInterrupt"
        "Super, mouse:274, global, caelestia:launcherInterrupt"
        "Super, mouse:275, global, caelestia:launcherInterrupt"
        "Super, mouse:276, global, caelestia:launcherInterrupt"
        "Super, mouse:277, global, caelestia:launcherInterrupt"
        "Super, mouse_up, global, caelestia:launcherInterrupt"
        "Super, mouse_down, global, caelestia:launcherInterrupt"
      ];
      bind = [
        # Launcher
        "ALT, SPACE, global, caelestia:launcher"

        # Misc
        "Super, L, global, caelestia:lock"
        "Super, N, exec, caelestia shell drawers toggle sidebar"

        # Utilities
        "Super+Shift, S, global, caelestia:screenshotFreeze" # Capture region (freeze)
        "Super+Shift+Alt, S, global, caelestia:screenshot" # Capture region
        "Super+Alt, R, exec, caelestia record -s" # Record screen with sound
        "Ctrl+Alt, R, exec, caelestia record" # Record screen
        "Super+Shift+Alt, R, exec, caelestia record -r" # Record region

        # Clipboard and emoji picker
        "Super, V, exec, pkill fuzzel || caelestia clipboard"
        "Super+Alt, V, exec, pkill fuzzel || caelestia clipboard -d"
        "Super, Period, exec, pkill fuzzel || caelestia emoji -p"
      ];
      bindl = [
        # Brightness
        ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
        ", XF86MonBrightnessDown, global, caelestia:brightnessDown"

        # Media
        "Ctrl+Super, Space, global, caelestia:mediaToggle"
        ", XF86AudioPlay, global, caelestia:mediaToggle"
        ", XF86AudioPause, global, caelestia:mediaToggle"
        "Ctrl+Super, Equal, global, caelestia:mediaNext"
        ", XF86AudioNext, global, caelestia:mediaNext"
        "Ctrl+Super, Minus, global, caelestia:mediaPrev"
        ", XF86AudioPrev, global, caelestia:mediaPrev"
        ", XF86AudioStop, global, caelestia:mediaStop"

        # Utilities
        ", Print, exec, caelestia screenshot" # Full screen capture > clipboard

        # Clipboard and emoji picker
        ''Ctrl+Shift+Alt, V, exec, sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"'' # Alternate paste
      ];
    };

    services.cliphist = {
      enable = true;
      allowImages = true;
    };
  };
}
