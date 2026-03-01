{inputs, ...}: {
  flake.nixosModules.services-playit = {config, ...}: {
    imports = [inputs.playit-nixos-module.nixosModules.default];

    services.playit = {
      enable = true;
      secretPath = config.sops.secrets."services/playit/secret".path;
    };

    sops.secrets."services/playit/secret" = {};
  };
}
