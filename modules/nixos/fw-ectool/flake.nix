{
  description = "fw-ectool for AMD laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ectoolSrc.url = "gitlab:DHowett/ectool?host=gitlab.howett.net";
    ectoolSrc.flake = false;
  };

  outputs = { self, nixpkgs, ectoolSrc, flake-utils }:
    let
      system = "x86_64-linux";
    
      pkgs = nixpkgs.legacyPackages.${system};

      ectoolpkg = pkgs.stdenv.mkDerivation {
        name = "ectool";
        src = ectoolSrc;

        buildInputs = with pkgs; [
          clang
          cmake
          git
          libftdi1
          libusb1
          ninja
          pkg-config
        ];

        buildPhase = ''
          mkdir -p $TMPDIR/build
          cd $TMPDIR/build
          CC=clang CXX=clang++ cmake -GNinja $src
          cmake --build .
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp $TMPDIR/build/src/ectool $out/bin/
        '';
      };
    in
    {
      packages.${system} = rec {
        fw-ectool = ectoolpkg;
        default = fw-ectool;

      };
      devShells.${system} = rec {
        fw-ectool = pkgs.mkShell { buildInputs = [ ectoolpkg ]; };
        default = fw-ectool;

      };
      overlays = rec {
        fw-ectool = final: prev: {
          fw-ectool = ectoolpkg;
        };
        default = fw-ectool;
      };
    };
}