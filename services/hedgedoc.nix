{inputs, ...}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.hedgedoc;
in {
  services.hedgedoc = {
    enable = true;
    settings = {
      inherit (evalSecrets) domain;
      allowAnonymous = true;
      allowGravatar = true;
      protocolUseSSL = true;
      host = "0.0.0.0";
    };
  };
}
