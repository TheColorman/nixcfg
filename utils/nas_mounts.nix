# https://wiki.nixos.org/wiki/NFS#Client
{
  fileSystems = {
    "/mnt/neodata/default" = {
      device = "colornas:/mnt/neodata/default";
      fsType = "nfs";
      options = [
        # Lazy-mount share since it's accessed through tailscale
        "x-systemd.automount"
        "noauto"
        # Disconnect the share after 10 minutes of inactivity
        "x-systemd.idle-timeout=600"
      ];
    };
    "/mnt/appsies/appdata" = {
      device = "colornas:/mnt/appsies/appdata";
      fsType = "nfs";
      options = [
        # Lazy-mount share since it's accessed through tailscale
        "x-systemd.automount"
        "noauto"
        # Disconnect the share after 10 minutes of inactivity
        "x-systemd.idle-timeout=600"
      ];
    };
  };
}
