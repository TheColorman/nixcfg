{
  config,
  lib,
  outputs,
  pkgs,
  ...
}: let
  cfg = config.my.beszel;
in {
  imports = [
    outputs.modules.services-sops
  ];
  options.my.beszel = {
    sopsSecrets = {
      key = lib.mkOption {
        type = lib.types.str;
        description = ''
          Name of the sops secret that contains the beszel agent secret for the
          particular host importing this module.
        '';
      };
      token = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Name of the sops secret that contains the beszel agent token for the
          particular host importing this module.
        '';
      };
    };
    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Extra environment variables for configuring the beszel-agent service.
        See <https://www.beszel.dev/guide/environment-variables#agent> for
        available options.
      '';
    };
  };
  config = {
    services.beszel.agent = {
      enable = true;
      environmentFile = config.sops.templates."beszel-agent.env".path;
      environment =
        {
          HUB_URL = "https://beszel.color";
        }
        // cfg.extraEnvironment;
      extraPath = with pkgs; [smartmontools];
    };

    systemd.services.beszel-agent.serviceConfig = {
      # smart data
      AmbientCapabilities = "CAP_SYS_RAWIO CAP_SYS_ADMIN";
      CapabilityBoundingSet = "CAP_SYS_RAWIO CAP_SYS_ADMIN";
      SupplementaryGroups = "disk";
      # systemd data
      DynamicUser = lib.mkForce false;
      User = "beszel-agent";
      Group = "beszel-agent";
      BusName = "org.freedesktop.systemd1";
    };

    users = {
      users."beszel-agent" = {
        isSystemUser = true;
        group = "beszel-agent";
      };
      groups."beszel-agent" = {};
    };

    sops = {
      secrets = lib.mkMerge [
        {
          "${cfg.sopsSecrets.key}" = {};
        }
        (lib.mkIf (cfg.sopsSecrets.token != null) {
          "${cfg.sopsSecrets.token}" = {};
        })
      ];

      templates."beszel-agent.env" = {
        content = ''
          KEY=${config.sops.placeholder."${cfg.sopsSecrets.key}"}
          ${lib.optionalString (cfg.sopsSecrets.token != null)
            "TOKEN=${config.sops.placeholder."${cfg.sopsSecrets.token}"}"}
        '';
        restartUnits = ["beszel-agent.service"];
      };
    };
  };
}
