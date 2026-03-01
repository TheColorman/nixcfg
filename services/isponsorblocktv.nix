{
  flake.nixosModules.services-isponsorblocktv = {
    virtualisation.oci-containers.containers.isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:latest";
      volumes = [
        "/var/lib/isponsorblocktv:/app/data"
      ];
      extraOptions = ["--network=host"];
    };
  };
}
