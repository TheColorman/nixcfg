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
    settings = {
      listen.http = "127.0.0.1:8080";
      email.from = "no-reply@${evalSecrets.emailDomain}";
    };

    environmentFile = config.sops.templates."authentik.env".path;
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
