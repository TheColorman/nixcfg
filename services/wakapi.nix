{
  inputs,
  outputs,
  config,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.wakapi;
in {
  imports = [
    outputs.modules.services-sops
  ];

  services.wakapi = {
    enable = true;
    settings = {
      server.public_url = evalSecrets.server.publicUrl;
      security = {
        insecure_cookies = false;
        allow_signup = false;
        disable_frontpage = true;
      };
      mail.enabled = false;
    };
    passwordSaltFile = config.sops.secrets."services/wakapi/passwordSalt".path;
  };

  sops.secrets."services/wakapi/passwordSalt".restartUnits = ["wakapi.service"];
}
