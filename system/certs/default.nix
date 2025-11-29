{
  imports = [./generateCa.nix ./certificateService.nix];

  # Include self-signed CA
  security.pki.certificateFiles = [./ca.pem];
}
