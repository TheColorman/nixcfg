{lib}: let
  importLibs = paths: let
    functionSets = builtins.map (path: import path {inherit lib;}) paths;
  in
    lib.lists.foldl (acc: set: acc // set) {} functionSets;
in
  importLibs [
    ./recurseModules.nix
    ./servant.nix
  ]
