# TODO: systemd mounts are created before tmpfiles, which means the mount
# sources don't actually exist on first boot, causing syncthing to fail
# entirely. I'm not sure how to resolve this issue short of completely
# forgoing bind mounts, but I like them for isolation. Perhaps symlinks
# could achieve something similar?
{
  config,
  inputs,
  outputs,
  lib,
  utils,
  systemName,
  pkgs,
  ...
}: let
  inherit (builtins) mapAttrs attrNames groupBy concatStringsSep concatLists;
  inherit (lib) types;
  inherit (lib.attrsets) filterAttrs mapAttrsToList mapAttrs' nameValuePair;
  inherit (lib.options) mkOption;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkMerge mkIf;
  inherit (utils) escapeSystemdPath;

  inherit (config.my) username;
  inherit
    ((import "${inputs.nix-secrets}/evaluation-secrets.nix").syncthing)
    devices
    ;

  cfg = config.my.syncthing;
  activeFolders = cfg.folders |> filterAttrs (_: v: v != null);

  folders = {
    brain = {
      id = "yedar-6vrrr";
      defaultPath = "/home/${username}/brain";
      devices = ["assassin"];
    };
    "Creative Cloud" = {
      id = "jdkuz-qjawg";
      defaultPath = "/home/${username}/CreativeCloud";
    };
    CTF = {
      id = "dh6gy-zxqu6";
      defaultPath = "/home/${username}/CTF";
    };
    ITU = {
      id = "yc39s-4wtgc";
      defaultPath = "/home/${username}/ITU";
    };
    nbns = {
      id = "lnicf-melst";
      defaultPath = "/home/${username}/nbns";
      type = "receiveencrypted";
      devices = ["nbns-desktop"];
    };
    Documents = {
      id = "wt32c-t7rkv";
      defaultPath = "/home/${username}/Documents";
      devices = ["assassin"];
    };
    projects = {
      id = "projects-e2cd04";
      defaultPath = "/home/${username}/projects";
    };
    Games = {
      id = "games-4db32c";
      defaultPath = "/home/${username}/Games";
    };
  };

  # Looks through my hosts config to find any other hosts that also use the
  # `my.syncthing.folders` option. Then reverses the map from
  # `hostname = ["list" "of" "syncthing" "folders"]` to
  # `folder = ["list" "of" "hosts"]`. This is used to determine what devices a
  # folder should be shared with, automatically sharing my syncthing folders
  # between all hosts that use them.
  otherHostFolders =
    inputs.self.nixosConfigurations
    |> filterAttrs (host: _: host != systemName)
    |> mapAttrs (
      _: module:
        module.config.my.syncthing.folders or {}
        |> filterAttrs (_folder: opts: opts != null)
        |> attrNames
    )
    |> mapAttrsToList (host:
      map (folder: {
        inherit folder host;
      }))
    |> concatLists
    |> groupBy (s: s.folder)
    |> mapAttrs (_folder: builtins.foldl' (hosts: hostSet: hosts ++ [hostSet.host]) []);

  syncthingSops = "services/syncthing/${systemName}";
in {
  imports = [outputs.modules.services-sops];
  options.my.syncthing = {
    enableMounts = mkOption {
      default = true;
      description = ''
        Whether to enable creating folder mounts in the users home directory.
        This will create folders in the users home directory which will be bind
        mounted into Syncthings dataDir. This option is enabled by default. If
        this option is enabled, all synced folders in the Syncthing dataDir
        will be deleted.
      '';
      type = types.bool;
    };

    folders =
      folders
      |> builtins.mapAttrs (_: folderOpts:
        mkOption {
          type = types.nullOr (types.submodule {
            options = {
              path = mkOption {
                type = types.path;
                default = folderOpts.defaultPath;
                description = ''
                  Path to place the folder at.
                '';
              };
              id = mkOption {
                type = types.str;
                default = folderOpts.id;
                readOnly = true;
              };
              devices = mkOption {
                type = types.listOf types.str;
                default = folderOpts.devices or [];
                readOnly = true;
              };
              type = mkOption {
                type = types.enum [
                  "sendreceive"
                  "sendonly"
                  "receiveonly"
                  "receiveencrypted"
                ];
                default = folderOpts.type or "sendreceive";
              };
            };
          });
          default = null;
        });
  };

  config = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";

      settings = {
        # Set devices from the imported secrets
        devices =
          devices
          |> mapAttrs (_: device: {
            inherit (device) id;
            addresses = ["dynamic"];
          });

        # Set folders calculated from other hosts' configs
        folders =
          activeFolders
          |> builtins.mapAttrs (name: value: {
            inherit (value) id type;
            # Folder is bind mounted to Syncthing's dataDir for easier
            # permission management
            path = "${config.services.syncthing.dataDir}/folders/${value.id}";
            devices = value.devices ++ otherHostFolders.${name} or [];
          });

        gui = {
          user = "${username}";
          password = "$2b$05$iIf0A4PpumRyB0PcXligbuF72WUrVvt1pGfjFuAfuwDVJDBHw.edy";
          theme = "dark";
          insecureAdminAccess = false;
        };

        options = {
          urAccepted = -1;
          localAnnounceEnabled = true;
        };
      };

      # Set the key and cert for this device
      key = config.sops.secrets."${syncthingSops}/key".path;
      cert = config.sops.secrets."${syncthingSops}/cert".path;
    };
    systemd = {
      # Ensure Syncthing starts after the bind mounts have been set up
      services.syncthing = {
        after =
          ["systemd-tmpfiles-setup.service"]
          ++
          # Only wait for mounts if mounting is enabled
          (optionals cfg.enableMounts (activeFolders
            |> mapAttrsToList (
              _folder: opts: escapeSystemdPath "${config.services.syncthing.dataDir}/folders/${opts.id}.mount"
            )));

        # Only require mounts if mounting is enabled
        requires =
          optionals cfg.enableMounts
          (activeFolders
            |> mapAttrsToList (
              _folder: opts: escapeSystemdPath "${config.services.syncthing.dataDir}/folders/${opts.id}.mount"
            ));
      };

      # Create the target folders, owned by main user
      tmpfiles.settings = mkMerge [
        {
          # Bindfs mountpoints that the Syncthing service will use
          # When mounts are disabled these are just the regular data folders.
          "syncthing-mountpoints" =
            activeFolders
            |> mapAttrs' (folder: opts:
              nameValuePair "${config.services.syncthing.dataDir}/folders/${opts.id}" {
                d = {
                  user = "syncthing";
                  group = "syncthing";
                  mode = "0750";
                };
              });
        }

        # Only create home folders if mounts are enabled
        (mkIf cfg.enableMounts {
          # Actual folders the user will use
          "syncthing-folders" =
            activeFolders
            |> mapAttrs' (folder: opts:
              nameValuePair opts.path {
                d = {
                  user = username;
                  group = "users";
                  mode = "0750";
                };
              });
        })
      ];

      # Set up bind mounts to mount the folders into Syncthing's directory
      mounts =
        # Only mount if mounting is enabled
        optionals cfg.enableMounts
        (activeFolders
          |> mapAttrsToList (_folder: opts: {
            # Source folder
            what = opts.path;
            # Where to bind mount
            where = "${config.services.syncthing.dataDir}/folders/${opts.id}";
            type = "fuse.bindfs";
            options = concatStringsSep "," [
              "force-user=syncthing"
              "force-group=syncthing"
              "create-for-user=${username}"
              "create-for-group=syncthing"
              # others
              "x-gvfs-hide"
              "x-gdu.hide"
              "multithreaded"
            ];
          }));
    };

    # key setup
    sops.secrets = {
      "${syncthingSops}/key" = {};
      "${syncthingSops}/cert" = {};
    };
    environment.systemPackages = [pkgs.bindfs];
  };
}
