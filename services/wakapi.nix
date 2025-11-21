{
  inputs,
  outputs,
  config,
  systemPlatform,
  ...
}: let
  evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.wakapi;
in {
  imports = with outputs.modules; [
    services-cloudflared
    services-sops
  ];

  services.wakapi = {
    # TODO: 2025-12 - Switch to stable version once stable is at 2.16.1
    package = let
      pkgs-unstable =
        import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/ba7b56a3b9c41c7e518cdcc8f02910936832469b.tar.gz";
          sha256 = "sha256:0b2ly9gc5y3i77a67yz9hw23xg050bdfcka3c36w57b539jn4d6f";
        }) {
          system = systemPlatform;
        };
    in
      pkgs-unstable.wakapi;
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
