{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  domain = "home.color";

  cfg = config.services.homepage-dashboard;
  crtCfg = config.my.certificates.certs."${domain}";

  backgroundImage = ../utils/stylix/assets/2026-H1.jpg;
  hosts =
    outputs.nixosConfigurations
    |> builtins.attrValues
    |> map (host: builtins.attrNames host.config.services.nginx.virtualHosts)
    |> lib.lists.flatten
    |> lib.lists.unique
    |> builtins.filter (domain: domain != "localhost");
in {
  services = {
    homepage-dashboard = {
      enable = true;
      package = pkgs.homepage-dashboard.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mkdir -p $out/share/homepage/public/images
            ln -s ${backgroundImage} $out/share/homepage/public/images/${builtins.baseNameOf backgroundImage}
          '';
      });
      allowedHosts = domain;

      settings = {
        title = "all the things...";
        description = "all the things...";
        background = {
          image = "images/${builtins.baseNameOf backgroundImage}";
          # saturate = 50;
          brightness = 50;
          # opacity = 80;
        };
        theme = "dark";
        color = "amber";
        quicklaunch = {
          provider = "custom";
          url = "https://kagi.com/search?q=";
          target = "_blank";
          suggestionUrl = "https://kagi.com/api/autosuggest?q=";
        };
        showStats = true;
        statusStyle = "dot";
      };

      widgets = [
        {
          datetime = {
            locale = "dk";
            format = {
              dateStyle = "long";
              timeStyle = "long";
            };
          };
        }
        {
          openmeteo = {
            timezone = config.time.timeZone;
            units = "metric";
            cache = 5;
          };
        }
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/mnt/neodata";
            cputemp = true;
            uptime = true;
            units = "metric";
            network = true;
          };
        }
      ];
    };

    # nginx.virtualHosts."${domain}" = {
    #   locations."/".proxyPass = "http://127.0.0.1:${toString cfg.listenPort}";
    #   forceSSL = true;
    #
    #   sslCertificateKey = crtCfg.key.path;
    #   sslCertificate = crtCfg.crt.path;
    # };
  };

  # my.certificates.certs."${domain}" = {};
}
