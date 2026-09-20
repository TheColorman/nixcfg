{
  flake.nixosModules.watcher-disko-config =
    { lib, ... }:
    {
      disko.devices = {
        disk = {
          main = {
            device = "/dev/disk/by-id/nvme-eui.0025388291b48942";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "500M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root = {
                  end = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };
}
