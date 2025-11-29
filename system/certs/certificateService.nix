# Systemd service that generates self-signed certificates using the local CA.
# Other modules can request certificates using this service. Much of the config
# here is copied from `options.security.acme`.
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.my.certificates.certs;

  commonServiceConfig = {
    Type = "oneshot";
    User = "certboy";
    Group = "certboy";
    UMask = "0022";
    StateDirectoryMode = "750";
    ProtectSystem = "strict";
    ReadWritePaths = [
      "/var/lib/certboy"
    ];

    CapabilityBoundingSet = [""];
    DevicePolicy = "closed";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    ProtectClock = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectControlGroups = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProcSubset = "pid";
    RemoveIPC = true;
    RestrictAddressFamilies = [];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      # 1. allow a reasonable set of syscalls
      "@system-service @resources"
      # 2. and deny unreasonable ones
      "~@privileged"
      # 3. then allow the required subset within denied groups
      "@chown"
    ];
  };

  mkCsrJson = domain:
    pkgs.writers.writeJSON "${domain}.csr.json" {
      key = {
        algo = "rsa";
        size = 2048;
      };
      CN = domain;
      hosts = [domain];
    };

  caConfig = pkgs.writers.writeJSON "ca-config.json" {
    signing.default = {
      usages = ["signing" "key encipherment" "server auth"];
      expiry = "720h"; # 24h * 30d = 720h
    };
  };
in {
  options.my.certificates.certs = lib.mkOption {
    default = {};
    type = with lib.types;
      attrsOf (submodule [
        ({
          name,
          config,
          ...
        }: {
          options = {
            directory = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = "/var/lib/certboy/${name}";
              description = ''
                Directory where certificate and other state is stored
              '';
            };

            reloadServices = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = ''
                The list of systemd services to call
                `systemctl try-reload-or-restart` on.
              '';
            };

            domain = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = ''
                Domain to generate certificate for (defaults to the entry name).
              '';
            };

            key.path = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = "${config.directory}/${config.domain}-key.pem";
            };

            crt.path = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = "${config.directory}/${config.domain}.pem";
            };

            csr.path = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = "${mkCsrJson config.domain}";
            };

            group = lib.mkOption {
              type = lib.types.str;
              default = "certboy";
              description = "Group with read access to apply to certificate.";
            };
          };
        })
      ]);
    description = ''
      Set of certificates to generate at runtime. Each certificate will be
      generated and signed by the local CA, with a 30-day expiration, with
      automatic renewal within 7 days of expiry.
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg != {}) {
      users = {
        users.certboy = {
          home = "/var/lib/certboy";
          homeMode = "755";
          group = "certboy";
          isSystemUser = true;
        };
        groups.certboy = {};
      };

      systemd.services = {
        "certboy-generate" = {
          description = "Ensure all self-signed certificates are generated";
          wantedBy = ["multi-user.target"];

          # Whenever this service starts (on boot, through dependencies, through
          # changes) we trigger the certboy-renew service to give it a chance
          # to catch up with the potentially changed config.
          wants = [
            "certboy-renew.service"
          ];
          before = ["certboy-renew.service"];

          restartTriggers = [config.systemd.services."certboy-renew".script];

          path = with pkgs; [cfssl];

          serviceConfig =
            commonServiceConfig
            // {
              UMask = "0027";
              RemainAfterExit = true;
              StateDirectory = "certboy";
            };

          script = let
            certGenScripts =
              cfg
              |> builtins.attrValues
              |> map ({
                key,
                crt,
                domain,
                directory,
                csr,
                ...
              }: ''
                # Check if .key and .crt file exists
                if [[ -f "${key.path}" && -f "${crt.path}" ]]; then
                  echo "Skipping ${domain} as key and cert exist."
                else
                  echo "Generating certificate for ${domain} at ${directory}"
                  mkdir -p "${directory}"

                  cfssl gencert \
                    -loglevel 2 \
                    -ca ${./ca.pem} \
                    -ca-key ${config.sops.secrets."certs/ca-key".path} \
                    -config ${caConfig} \
                    "${csr.path}" \
                    | cfssljson -bare "${directory}/${domain}"
                fi
              '')
              |> lib.concatLines;
          in ''
            set -ex

            echo "Generating certificates"

            ${certGenScripts}

            echo "Finished generating certificates!"
          '';
        };
        "certboy-renew" = {
          description = "Ensure all self-signed certificates are renewed";
          after = ["certboy-generate.service"];
          wants = ["certboy-generate.service"];

          path = with pkgs; [cfssl jq];

          serviceConfig =
            commonServiceConfig
            // {
              RestartSec = 15 * 60; # 60s * 15m = 15m

              ExecStartPost = let
                renewPostrunScript =
                  cfg
                  |> builtins.attrValues
                  |> map ({
                    directory,
                    reloadServices,
                    group,
                    ...
                  }: ''
                    cd "${directory}"
                    if [ -e renewed ]; then
                      rm renewed
                      ${lib.optionalString (
                        reloadServices != []
                      ) "systemctl --no-block try-reload-or-restart ${
                        lib.escapeShellArgs reloadServices
                      }"}
                    fi

                    chmod -R u=rwX,g=rX,o= "${directory}"
                    chown -R certboy:${group} "${directory}"
                  '')
                  |> lib.concatLines;
              in
                "+"
                + (pkgs.writeShellScript "certboy-renew-postrun"
                  renewPostrunScript);
            };

          script = let
            certRenewScripts =
              cfg
              |> builtins.attrValues
              |> map (
                {
                  key,
                  crt,
                  domain,
                  csr,
                  directory,
                  ...
                }: ''
                  # Check if .key and .crt file exists
                  if [[ -f "${key.path}" && -f "${crt.path}" ]]; then
                    expiry="$(cfssl certinfo -cert "${crt.path}" | jq -r '.not_after')"
                    expiry_epoch="$(date -d "$expiry" +%s)"
                    time_until_expiry="$((expiry_epoch - NOW_EPOCH))"

                    echo "${domain} expires at $expiry (in $((time_until_expiry / 86400)) days)"

                    if [ $time_until_expiry -lt $SEVEN_DAYS ]; then
                      echo "Certificate expires in less than 7 days. Renewing..."
                      cfssl gencert \
                        -loglevel 2 \
                        -ca ${./ca.pem} \
                        -ca-key ${config.sops.secrets."certs/ca-key".path} \
                        -config ${caConfig} \
                        "${csr.path}" \
                        | cfssljson -bare ${directory}/${domain}

                      touch renewed
                    else
                      echo "Skipping ${domain} as it is valid for more than 7 days"
                    fi

                  else
                    echo "Skipping ${domain} as key or cert does not exist."
                  fi
                ''
              )
              |> lib.concatLines;
          in ''
            set -euo pipefail

            echo "Renewing certificates"

            NOW_EPOCH="$(date +%s)"
            SEVEN_DAYS="$((7 * 24 * 60 * 60))"

            ${certRenewScripts}

            echo "Finished reniewing certificates!"
          '';
        };
      };

      sops.secrets."certs/ca-key".owner = "certboy";
    })
  ];
}
