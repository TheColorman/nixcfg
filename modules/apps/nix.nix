{ pkgs, outputs, lib, config, ... }:
let
  inherit (lib.meta) getExe;
  user = config.my.username;
  script = name: text: pkgs.writeShellApplication { inherit name text; };
  flakedir = "/home/${user}/nixcfg";

  gitTagScript = ''
    generation=$(nix-env --list-generations | grep current | awk '{print $1}')
    echo "Built generation $generation."
    read -r -p "Create git tag? [Y/n]: " choice

    choice=''${choice:-Y}

    if [[ "$choice" == [Yy] ]]; then
      pushd ${flakedir} > /dev/null
      ${getExe pkgs.git} tag -a "$generation" -m "Build $generation"
      ${getExe pkgs.git} push --tag
      popd > /dev/null
    fi
  '';
in
{
  imports = [ outputs.modules.apps-nh ];
  environment.systemPackages = [
    (script "tnix"  "nh os test --verbose ${flakedir}")
    (script "dbnix" "nh os build --dry ${flakedir}")
    (script "danix" "nh os test --dry ${flakedir}")
    (script "bnix"  ''
      nh os boot ${flakedir}

      ${gitTagScript}
    '')
    (script "snix" ''
      nh os switch ${flakedir}

      ${gitTagScript} 
    '')
  ];
}
