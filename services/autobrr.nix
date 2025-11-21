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
        nixpkgs-unstable = fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/ba7b56a3b9c41c7e518cdcc8f02910936832469b.tar.gz";
          sha256 = "sha256:0b2ly9gc5y3i77a67yz9hw23xg050bdfcka3c36w57b539jn4d6f";
        };
      in
        (import nixpkgs-unstable {
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
