{
  flake.nixosModules.services-isponsorblocktv = {
    virtualisation.oci-containers.containers.isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.11.0@sha256:d1e876636754fb2b54490feebe3af4a321f7f2a932a2d57b67b2a667eea40823";
      volumes = [
        "/var/lib/isponsorblocktv:/app/data"
      ];
      extraOptions = [ "--network=host" ];
    };
  };
}
