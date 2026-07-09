{
  flake.nixosModules.lancer-disko-config =
    { lib, ... }:
    {
      disko.devices = {
        disk = {
          lancer = {
            type = "disk";
            device = "/dev/disk/by-id/usb-FRMW_1TB_Card_071C426EAF8EC616-0:0";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "1G";
                  type = "EF00"; # EFI System Partition
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                swap = {
                  size = "8G";
                  content = {
                    type = "swap";
                    randomEncryption = true;
                  };
                };
                root = {
                  size = "100%";
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
