/**
* This module recursively searches a directory for Nix files and returns an
* attribute set where the keys are the module names (without suffixes) and the
* values are the paths to those modules.
*/
{lib}: {
  recurseModules = path: let
    inherit (builtins) readDir;
    inherit (lib.attrsets) mapAttrsToList filterAttrs mapAttrs' nameValuePair;
    inherit (lib.lists) flatten foldl';
    inherit (lib.strings) hasSuffix removeSuffix;

    # creates an attrset in the form
    # { dir-subdir-module.nix = "/path/to/dir/subdir/module.nix"; ... }
    recursiveFileSearch = path: friendlyPrefix:
      flatten (mapAttrsToList
        (fname: type: let
          filepath = "${path}/${fname}";
        in
          if type == "regular"
          then {"${friendlyPrefix}${fname}" = filepath;}
          else recursiveFileSearch filepath "${friendlyPrefix}${fname}-")
        (readDir path));
    files = foldl' (acc: x: acc // x) {} (recursiveFileSearch path "");
    nixFiles = filterAttrs (name: _value: hasSuffix ".nix" name) files;
    modules =
      mapAttrs'
      (
        name: value:
          nameValuePair (removeSuffix "-default" (removeSuffix ".nix" name)) value
      )
      nixFiles;
  in
    modules;
}
