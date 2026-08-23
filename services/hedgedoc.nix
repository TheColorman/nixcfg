{ inputs, ... }:
{
  flake.nixosModules.services-hedgedoc =
    { config, ... }:
    let
      evalSecrets = import "${inputs.nix-secrets}/evaluation-secrets.nix";
      hedgedocSecrets = evalSecrets.services.hedgedoc;
      authentikSecrets = evalSecrets.services.authentik;

      port = 37192;
    in
    {
      services.hedgedoc = {
        enable = true;
        settings = {
          inherit (hedgedocSecrets) domain;
          allowAnonymous = true;
          allowGravatar = true;
          protocolUseSSL = true;
          host = "127.0.0.1";
          inherit port;

          # Disable email sign-in, force oauth2
          email = false;
          oauth2 = {
            userProfileURL = "https://${authentikSecrets.domain}/application/o/userinfo/";
            userProfileUsernameAttr = "preferred_username";
            userProfileDisplayNameAttr = "name";
            userProfileEmailAttr = "email";
            tokenURL = "https://${authentikSecrets.domain}/application/o/token/";
            authorizationURL = "https://${authentikSecrets.domain}/application/o/authorize/";
            scope = "openid email profile";
          };
        };

        environmentFile = config.sops.templates."hedgedoc.env".path;
      };

      my.cloudflared.tunnels.hedgedoc.tokenFile =
        config.sops.secrets."services/hedgedoc/tunnel_token".path;

      sops = {
        secrets = {
          "services/hedgedoc/tunnel_token" = { };
          "services/hedgedoc/clientId" = { };
          "services/hedgedoc/clientSecret" = { };
        };

        templates."hedgedoc.env".content = ''
          CMD_OAUTH2_CLIENT_ID=${config.sops.placeholder."services/hedgedoc/clientId"}
          CMD_OAUTH2_CLIENT_SECRET=${config.sops.placeholder."services/hedgedoc/clientSecret"}
        '';
      };
    };
}
