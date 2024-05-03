{ lib }:
with lib;
let
  nixosModuleDirectories = attrNames
      (filterAttrs (_k: v: v == "directory")
      (builtins.readDir ../modules/nixos));
  flakeDirectories = filter
    (dir: builtins.pathExists ../modules/nixos/${dir}/flake.nix)
    nixosModuleDirectories;
  
  flakeAttrset = mergeAttrsList
    (imap0 (_i: dir: {
      "${dir}" = {
        url = "path:./modules/nixos/${dir}";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    }) flakeDirectories);
in
  flakeAttrset