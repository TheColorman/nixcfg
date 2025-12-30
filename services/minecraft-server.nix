{systemPlatform, ...}: {
  services.minecraft-server = {
    enable = true;
    eula = true;
    package = let
      # Get newest release, 1.21.11
      pkgs-unstable =
        import (fetchTarball {
          url = "https://github.com/nixos/nixpkgs/archive/ffbc9f8cbaacfb331b6017d5a5abb21a492c9a38.tar.gz";
          sha256 = "sha256:0fvbizl7j5rv2rf8j76yw0xb3d9l06hahkjys2a7k1yraznvnafm";
        }) {
          system = systemPlatform;
          config.allowUnfree = true;
        };
    in
      pkgs-unstable.minecraft-server;
  };
}
