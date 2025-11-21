{
  inputs,
  outputs,
  config,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.hedgedoc;

  port = 37192;
in {
  imports = [
    outputs.modules.services-cloudflared
  ];

  services.hedgedoc = {
    enable = true;
    settings = {
      inherit (evalSecrets) domain;
      allowAnonymous = true;
      allowGravatar = true;
      protocolUseSSL = true;
      host = "127.0.0.1";
      inherit port;
    };
  };

  my.cloudflared.tunnels.hedgedoc.tokenFile = config.sops.secrets."services/hedgedoc/tunnel_token".path;

  sops.secrets."services/hedgedoc/tunnel_token" = {};
}
