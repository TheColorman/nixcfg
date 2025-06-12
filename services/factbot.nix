{
  inputs,
  outputs,
  systemPlatform,
  config,
  ...
}: {
  imports = [
    inputs.factbot.modules."${systemPlatform}".default
    outputs.modules.services-sops
  ];

  services.factbot.instances = let
    inherit (config.sops.secrets) fact_bot_english_token fact_bot_danish_token;
  in {
    english = {
      enable = true;
      tokenFile = fact_bot_english_token.path;
    };
    danish = {
      enable = true;
      tokenFile = fact_bot_danish_token.path;
    };
  };

  sops.secrets = {
    fact_bot_danish_token = {
      reloadUnits = ["factbot-danish.service"];
      path = "/var/lib/factbot-danish/token";
    };
    fact_bot_english_token = {
      reloadUnits = ["factbot-english.service"];
      path = "/var/lib/factbot-english/token";
    };
  };
}
