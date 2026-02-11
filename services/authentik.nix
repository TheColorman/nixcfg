{
  inputs,
  config,
  outputs,
  ...
}: let
  evalSecrets =
    (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.authentik;
in {
  imports = [
    inputs.authentik-nix.nixosModules.default
    outputs.modules.services-cloudflared
  ];

  services.authentik = {
    enable = true;

    nginx = {
      enable = true;
      host = evalSecrets.domain;
    };
  };

  my.cloudflared.tunnels.authentik.tokenFile =
    config.sops.secrets."services/authentik/tunnelToken".path;

  sops = {
    secrets = {
      "services/authentik/tunnelToken" = {};
      "services/authentik/secretKey" = {};
    };

    templates."authentik.env".content = ''
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder."services/authentik/secretKey"}
    '';
  };
}
