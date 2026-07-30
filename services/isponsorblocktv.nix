{
  flake.nixosModules.services-isponsorblocktv = {
    virtualisation.oci-containers.containers.isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv:v2.10.0@sha256:f2e4c7e57f6fcb490156759bcc79561ac594675354923a71f1f034a3fe39d7de";
      volumes = [
        "/var/lib/isponsorblocktv:/app/data"
      ];
      extraOptions = [ "--network=host" ];
    };
  };
}
