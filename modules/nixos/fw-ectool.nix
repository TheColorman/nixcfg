{
  description = "fw-ectool for AMD laptops";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ectoolSrc = {
      url = "gitlab:DHowett/ectool?host=gitlab.howett.net";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, inputs, ... }@inputs:
  let
    version = "0.1.${nixpkgs.lib.substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    ectool = pkgs.stdenv.mkDerivation {
      name = "ectool";
      inherit version;
      src = inputs.ectoolSrc;
    };

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
  in
  {
    packages.${system}.ectool = ectool;
    defaultPackage.${system} = ectool;
  };
}