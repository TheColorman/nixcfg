{
  outputs,
  lib,
  config,
  ...
}: let
  hosts =
    outputs.nixosConfigurations
    |> builtins.attrValues
    |> map (host: builtins.attrNames host.config.services.nginx.virtualHosts)
    |> lib.lists.flatten
    |> lib.lists.unique
    |> builtins.filter (domain: domain != "localhost");
in {
  services.homepage-dashboard = {
    enable = true;
    settings = {
      title = "all the things...";
      background = {
        image = ./background.jpg;
        blur = "sm";
        saturate = 50;
        brightness = 50;
        opacity = 50;
      };
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

    bookmarks = [
      {
        Services =
          hosts
          |> map (host: {
            "${host}".href = host;
          });
      }
    ];

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
}
