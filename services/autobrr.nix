{
  outputs,
  config,
  systemPlatform,
  ...
}: let
  port = 7474;
in {
  imports = [
    outputs.modules.services-sops
  ];

  nixpkgs.overlays = [
    (_final: _prev: {
      autobrr = let
        # TODO: 2025-11-22 - Requires Autobrr 1.69.0. Currently not merged.
        # 1. Replace this with nixos-unstable package once #461598 is merged
        #    and has reached unstable.
        # 2. Replace with nixos-25.11 once that is released, assuming it will
        #    contain 1.69.0 (it probably wont, it was merged too late).
        very-unstable-nixpkgs = fetchTarball {
          url = "https://github.com/r-ryantm/nixpkgs/archive/ebe96f7698d0cd1ba8474fb9521f09ea0142b98f.tar.gz";
          sha256 = "sha256:0611y4v8lrxk21bqgijannmaz72b0pqipzkm5iqf9a9kx69450wj";
        };
      in
        (import very-unstable-nixpkgs {
          system = systemPlatform;
        }).pkgs.autobrr;
    })
  ];

  services.autobrr = {
    enable = true;
    secretFile = config.sops.secrets."services/autobrr/sessionSecret".path;
    settings = {
      host = "0.0.0.0";
      inherit port;
      logLevel = "DEBUG";
      checkForUpdates = true;
    };
  };

  networking.firewall.allowedTCPPorts = [port];

  sops.secrets."services/autobrr/sessionSecret" = {
    reloadUnits = ["autobrr.service"];
  };
}
