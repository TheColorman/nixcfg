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
          package = pkgs.mpv.override {
            scripts = with pkgs.mpvScripts; [
              videoclip
              mpris
            ];
            # videoclip invokes the ffmpeg CLI to encode clips.
            extraMakeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              (lib.makeBinPath [
                pkgs.ffmpeg
                pkgs.xdg-user-dirs
              ])
            ];
          };
          enable = true;

          config = {
            # Preserve HDR colorspace hints while using the compatible renderer.
            target-colorspace-hint = "yes";
            vo = "gpu";

            # Set demuxer cache limits (these are mpv options, not videoclip options).
            demuxer-max-bytes = 2147483648; # 2 GiB
            demuxer-max-back-bytes = 524288000; # 500 MiB
          };
        };
        # Mostly copied from videoclip readme
        xdg.configFile."mpv/script-opts/videoclip.conf".text = ''
          # Absolute paths to the folders where generated clips will be placed.
          # `~` or `$HOME` are not supported due to mpv limitations.
          video_folder_path=/home/${username}/Videos
          audio_folder_path=/home/${username}/Music

          # Menu size
          font_size=24

          # OSD settings. Line alignment: https://aegisub.org/docs/3.2/ASS_Tags/#\an
          osd_align=7
          osd_outline=1.5

          # Clean filenames (remove special characters) (yes or no)
          clean_filename=yes

          # Video settings
          video_width=-2
          video_height=480
          video_bitrate=1M
          # Available video formats: mp4, vp9, vp8
          video_format=mp4
          # The range of the scale is 0–51, where 0 is lossless,
          # 23 is the default, and 51 is worst quality possible.
          # Insane values like 9999 still work but produce the worst quality.
          video_quality=23
          # Use the slowest preset that you have patience for.
          # https://trac.ffmpeg.org/wiki/Encode/H.264
          preset=faster
          # FPS / framerate. Set to "auto" or a number.
          video_fps=auto
          #video_fps=60

          # Audio settings
          # Available formats: opus or aac
          audio_format=opus
          # Opus sounds good at low bitrates 32-64k, but aac requires 128-256k.
          audio_bitrate=32k

          # Catbox.moe upload settings
          # Whether uploads should go to litterbox instead of catbox.
          # catbox files are stored permanently, while litterbox is temporary
          litterbox=yes
          # If using litterbox, time until video expires
          # Available values: 1h, 12h, 24h, 72h
          litterbox_expire=72h
        '';
      };
    };
}
