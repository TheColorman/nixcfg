{ inputs, ...}: {
  flake.nixosModules.apps-ki = { pkgs, ...}: {
    environment.systemPackages = [
      inputs.ki-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
} 