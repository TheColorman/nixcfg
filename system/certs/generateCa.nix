{
  pkgs,
  lib,
  ...
}: let
  caCsr = pkgs.writers.writeJSON "caCsr.json" {
    key = {
      algo = "rsa";
      size = 2048;
    };
    CN = "color-ca";
    hosts = ["color-ca"];
  };
in {
  options.my.certificates.generateCa = lib.mkOption {
    description = ''
      Script to generate a Certificate Authority for self-signed certificates.
      Should ideally only be used once. The public key of the CA generated
      using this script should be placed in `system/certs/ca.pem`.
    '';
    type = lib.types.package;
    readOnly = true;
    default = pkgs.writeShellApplication {
      name = "generate-ca";
      runtimeInputs = [pkgs.cfssl];
      text = ''
        cfssl gencert -loglevel 2 -initca "${caCsr}" | cfssljson -bare ca
      '';
    };
  };
}
