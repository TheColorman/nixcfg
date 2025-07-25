{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (config.my) username;

  script = name: text: pkgs.writeShellApplication {inherit name text;};
  flakedir = "/home/${username}/nixcfg";
  flake = "--flake ${flakedir}";

  gitTagScript = ''
    generation=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
    host=$(hostname)
    echo "Built generation $generation for $host."
    tag="$generation-$host"
    read -r -p "Create git tag ($tag)? [Y/n]: " choice

    choice=''${choice:-Y}

    if [[ "$choice" == [Yy] ]]; then
      pushd ${flakedir} > /dev/null
      sha=$(git rev-parse --short HEAD)
      ${getExe pkgs.git} tag -a "$tag" -m "Build $generation for $host at \\\`github:TheColorman/nixcfg/$sha\\\`"
      ${getExe pkgs.git} push --tag
      popd > /dev/null
    fi
  '';
in {
  environment.systemPackages = [
    (script "tnix" "sudo nixos-rebuild test ${flake} -L -v")
    (script "dbnix" "sudo nixos-rebuild dry-build ${flake} -L -v")
    (script "danix" "sudo nixos-rebuild dry-activate ${flake} -L -v")
    (script "bnix" ''
      sudo nixos-rebuild boot ${flake}

      ${gitTagScript}
    '')
    (script "snix" ''
      sudo nixos-rebuild switch ${flake}

      ${gitTagScript}
    '')
  ];
}
