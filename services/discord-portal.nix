{
  config,
  inputs,
  outputs,
  systemPlatform,
  ...
}: {
  imports = [
    inputs.discord-portal.modules."${systemPlatform}".default
    outputs.modules.services-sops
  ];

  services.discord-portal.instances.main = {
    enable = true;
    tokenFile = config.sops.secrets.portal_token.path;
  };

  sops.secrets.portal_token = {
    reloadUnits = ["discord-portal-main.service"];
    path = "/var/lib/discord-portal-main/token";
  };
}
