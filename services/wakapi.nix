{
  inputs,
  outputs,
  config,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.wakapi;
in {
  imports = with outputs.modules; [
    services-cloudflared
    services-sops
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

      db = {
        dialect = "postgres";
        host = "127.0.0.1";
        port = 5432;
        name = "wakapi";
        user = "wakapi";
        ssl = false;
      };
    };

    database.createLocally = true;

    passwordSaltFile = config.sops.templates."wakapi.env".path;
  };

  my.cloudflared.tunnels.wakapi.tokenFile = config.sops.secrets."services/wakapi/tunnel_token".path;
  sops = {
    secrets = {
      "services/wakapi/passwordSalt" = {};
      "services/wakapi/tunnel_token" = {};
    };

    templates."wakapi.env" = {
      content = ''
        WAKAPI_PASSWORD_SALT=${config.sops.placeholder."services/wakapi/passwordSalt"}
      '';
      restartUnits = ["wakapi.service"];
    };
  };
}
