{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (config.my) username;

  flakedir = "/home/${username}/nixcfg";

  rebuildScript = name: text:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        # Build the system
        outpath="$(nom build \
          ${flakedir}\#nixosConfigurations."$(hostname)".config.system.build.toplevel \
          --no-link \
          --print-out-paths)"

        switch_cmd="''${outpath}/bin/switch-to-configuration"

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
    (rebuildScript "tnix" ''
      sudo "$switch_cmd" test
    '')
    (rebuildScript "dbnix" ''
      sudo "$switch_cmd" dry-build
    '')
    (rebuildScript "danix" ''
      sudo "$switch_cmd" dry-activate
    '')
    (rebuildScript "bnix" ''
      sudo "$switch_cmd" boot

      ${gitTagScript}
    '')
    (rebuildScript "snix" ''
      sudo "$switch_cmd" switch

      ${gitTagScript}
    '')
  ];
}
