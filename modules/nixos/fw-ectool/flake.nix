{
  description = "fw-ectool for AMD laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ectoolSrc.url = "gitlab:DHowett/ectool?host=gitlab.howett.net";
    ectoolSrc.flake = false;
  };

  outputs = { self, nixpkgs, ectoolSrc, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        ectool = pkgs.stdenv.mkDerivation {
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
        packages.ectool = ectool;
        packages.default = self.packages.${system}.ectool;
        
        devShells.ectool = pkgs.mkShell { buildInputs = [ ectool ]; };
        devShells.default = self.devShells.${system}.ectool;
      });
}