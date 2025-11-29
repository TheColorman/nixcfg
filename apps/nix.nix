{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (config.my) username;

  flakedir = "/home/${username}/nixcfg";
  flake = "--flake ${flakedir}";

  rebuildScript = name: text:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        # Build the system
        nom build \
          ${flakedir}\#nixosConfigurations."$(hostname)".config.system.build.toplevel \
          --no-link

        ${text}
      '';
    };

  gitTagScript = ''
    generation=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
    host=$(hostname)
    echo "Built generation $generation for $host."
    tag="$host-$generation"
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
    pkgs.nix-output-monitor
    (rebuildScript "tnix" "sudo nixos-rebuild test ${flake}")
    (rebuildScript "dbnix" "sudo nixos-rebuild dry-build ${flake}")
    (rebuildScript "danix" "sudo nixos-rebuild dry-activate ${flake}")
    (rebuildScript "bnix" ''
      sudo nixos-rebuild boot ${flake}

      ${gitTagScript}
    '')
    (rebuildScript "snix" ''
      sudo nixos-rebuild switch ${flake}

      ${gitTagScript}
    '')
  ];
}
