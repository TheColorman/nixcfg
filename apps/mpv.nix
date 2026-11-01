{
  flake.nixosModules.apps-mpv =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.my) username;
    in
    {
      home-manager.users."${username}" = {
        programs.mpv = {
          # Keep mpv, its scripts, and the host graphics stack on the same
          # nixpkgs revision. Use `gpu` to work around mpv 0.41's HDR issue
          # with Hyprland: https://github.com/mpv-player/mpv/issues/17204
          enable = true;
          scripts = with pkgs.mpvScripts; [
            videoclip
            mpris
          ];

          # videoclip invokes these tools; keep them in mpv's runtime PATH.
          extraMakeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            (lib.makeBinPath [
              pkgs.ffmpeg
              pkgs.xdg-user-dirs
            ])
          ];

          scriptOpts.videoclip = {
            # Absolute paths; mpv does not expand ~ or $HOME here.
            video_folder_path = "/home/${username}/Videos";
            audio_folder_path = "/home/${username}/Music";

            font_size = 24;
            osd_align = 7;
            osd_outline = 1.5;
            clean_filename = true;

            video_width = -2;
            video_height = 480;
            video_bitrate = "1M";
            video_format = "mp4";
            video_quality = 23;
            preset = "faster";
            video_fps = "auto";

            audio_format = "opus";
            audio_bitrate = "32k";

            litterbox = true;
            litterbox_expire = "72h";
          };

          config = {
            # Preserve HDR colorspace hints while using the compatible renderer.
            target-colorspace-hint = "yes";
            vo = "gpu";

            # Set demuxer cache limits (these are mpv options, not videoclip options).
            demuxer-max-bytes = 2147483648; # 2 GiB
            demuxer-max-back-bytes = 524288000; # 500 MiB
          };
        };
      };
    };
}
