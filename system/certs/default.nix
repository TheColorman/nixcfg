{self, ...}: {
  flake.nixosModules.system-certs = {
    imports = with self.nixosModules; [
      system-certs-certificateService
      system-certs-generateCa
    ];

    # Include self-signed CA
    security.pki.certificateFiles = [./ca.pem];
  };
}
