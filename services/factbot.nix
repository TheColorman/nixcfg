{
  inputs,
  systemPlatform,
  config,
  ...
}: {
  imports = [inputs.factbot.modules."${systemPlatform}".default];

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
}
