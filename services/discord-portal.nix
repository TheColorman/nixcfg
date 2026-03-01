{inputs, ...}: {
  flake.nixosModules.services-discord-portal = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.discord-portal.modules."${pkgs.stdenv.hostPlatform.system}".default
    ];

    services.discord-portal.instances.main = {
      enable = true;
      tokenFile = config.sops.secrets.portal_token.path;
    };

    sops.secrets.portal_token = {
      reloadUnits = ["discord-portal-main.service"];
      path = "/var/lib/discord-portal-main/token";
    };
  };
}
