{
  flake.nixosModules.services-syncthing =
    {
      config,
      lib,
      utils,
      pkgs,
      ...
    }:
    let
      inherit (config.my) username;
    in
    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        guiAddress = "0.0.0.0:8384";
      };

      systemd.tmpfiles.rules = [
        "a+ /home/${username} - - - - u:syncthing:--x,m::--x"
      ];
    };
}
