{ inputs, ... }: {
  flake.nixosModules.services-jellyfin =
    {
      config,
      ...
    }:
    let
      domain = "jellyfin.color";

      crtCfg = config.my.certificates.certs."${domain}";
    in
    {
      imports = [ inputs.ffmpeg-over-ip.nixosModules.ffmpeg-over-ip ];

      nixpkgs.overlays = [ inputs.ffmpeg-over-ip.overlays.default ];

      services = {
        # https://jellyfin.org/docs/general/post-install/networking/
        # Port  Protocol  Configurable  Description
        # 8096  TCP        ✔️           Default HTTP
        # 8920  TCP        ✔️           Default HTTPS
        # 7359  UDP        ❌           Client Discovery
        jellyfin.enable = true;

        nginx.virtualHosts."${domain}" = {
          locations."/".proxyPass = "http://127.0.0.1:30013";
          forceSSL = true;

          sslCertificateKey = crtCfg.key.path;
          sslCertificate = crtCfg.crt.path;
        };

        ffmpeg-over-ip-client = {
          enableJellyfinIntegration = true;
          hostname = "brawl";
          authSecretFile = config.sops.secrets."services/ffmpeg-over-ip/shared_secret".path;
          debug = true;
          log = "/var/log/ffmpeg-over-ip-client.log";
          fallbackToLocal = true;
          # TODO: Figure out which args are actually used and need to be rewritten.
          fallbackRewrites = [
            # Remove VA-API device initialization
            [
              "-init_hw_device vaapi=va:,vendor_id=0x8086,driver=iHD"
              ""
            ]

            # Remove QSV device initialization
            [
              "-init_hw_device qsv=qs@va"
              ""
            ]

            # Remove QSV filter device
            [
              "-filter_hw_device qs"
              ""
            ]

            # Remove VA-API hardware decoding
            [
              "-hwaccel vaapi -hwaccel_output_format vaapi"
              ""
            ]

            # Replace the complete VA-API/QSV filter graph with software filters
            [
              "setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709,scale_vaapi=w=960:h=540:format=nv12:extra_hw_frames=24,hwmap=derive_device=qsv,format=qsv"
              "setparams=color_primaries=bt709:color_trc=bt709:colorspace=bt709,scale=960:540:flags=fast_bilinear,format=yuv420p"
            ]

            # Replace QSV AV1 encoder with software AV1 encoder
            [
              "-codec:v:0 av1_qsv"
              "-codec:v:0 libsvtav1"
            ]

            # Remove the QSV preset: SVT-AV1 uses a numeric preset
            [
              "-preset veryfast"
              ""
            ]
          ];
        };
      };

      networking.firewall = {
        allowedTCPPorts = [ 30013 ];
        allowedUDPPorts = [ 30013 ];
      };
      my = {
        certificates.certs."${domain}" = { };
        cloudflared.tunnels.jellyfin.tokenFile = config.sops.secrets."services/jellyfin/tunnel_token".path;
      };
      sops.secrets = {
        "services/jellyfin/tunnel_token" = { };
        "services/ffmpeg-over-ip/shared_secret" = { };
      };
    };
}
