{ pkgs, outputs, ... }:
let
  script = name: text: pkgs.writeShellApplication { inherit name text; };
in
{
  imports = [ outputs.modules.apps-nh ];
  environment.systemPackages = [
    (script "tnix"  "nh os test --verbose")
    (script "dbnix" "nh os build --dry")
    (script "danix" "nh os test --dry")
    (script "snix"  "nh os switch")
    (script "bnix"  "nh os build")
  ];
}
