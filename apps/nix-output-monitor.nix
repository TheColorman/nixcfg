{
  pkgs,
  inputs,
  systemPlatform,
  ...
}: {
  environment.systemPackages = [pkgs.nix-output-monitor];

  # Use unstable git version of nom
  nixpkgs.overlays = [
    (_final: _prev: {
      nix-output-monitor =
        inputs.nix-output-monitor.packages.${systemPlatform}.default;
    })
  ];
}
