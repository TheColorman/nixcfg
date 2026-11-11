{
  flake.nixosModules.services-syncthing =
    {
      config,
      lib,
      utils,
      pkgs,
      ...
    }:
    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        guiAddress = "0.0.0.0:8384";
      };
    };
}
