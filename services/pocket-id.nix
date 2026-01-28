{
  inputs,
  config,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.pocket;
in {
  services.pocket-id = {
    enable = true;
    settings = {
      TRUST_PROXY = true;
      APP_URL = "https://${evalSecrets.domain}";
      ANALYTICS_DISABLED = true;
    };
  };

  my.cloudflared.tunnels.pocket-id.tokenFile = config.sops.secrets."services/pocketid/tunnelToken".path;

  sops = {
    secrets = {
      "services/pocketid/encryptionKey" = {};
      "services/pocketid/tunnelToken" = {};
    };

    templates."pocketid.env" = {
      content = ''
        ENCRYPTION_KEY=${config.sops.placeholder."services/pocketid/encryptionKey"}
      '';
      restartUnits = ["pocket-id.service"];
    };
  };
}
