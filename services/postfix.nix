{inputs, ...}: {
  flake.nixosModules.services-postfix = {config, ...}: let
    evalSecrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").services.postfix;
    relayHost = "[${evalSecrets.smtpRelayUrl}]:2525";
  in {
    services.postfix = {
      enable = true;
      settings.main = {
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_password_maps = "texthash:${
          config.sops.templates."postfix_smtp_relay_login".path
        }";
        smtp_sasl_security_options = "noanonymous";
        smtp_tls_security_level = "may";
        header_size_limit = 4096000;
        relayhost = [relayHost];
        relay_destination_concurrency_limit = 20;
      };
    };

    sops = {
      secrets = {
        "services/postfix/relay_user" = {};
        "services/postfix/relay_password" = {};
      };

      templates."postfix_smtp_relay_login" = {
        content = let
          user = config.sops.placeholder."services/postfix/relay_user";
          pass = config.sops.placeholder."services/postfix/relay_password";
        in ''
          ${relayHost} ${user}:${pass}
        '';
        restartUnits = ["postfix.service"];
      };
    };
  };
}
