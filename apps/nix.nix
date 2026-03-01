{
  flake.nixosModules.apps-nix = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib.meta) getExe;
    inherit (config.my) username;

    flakedir = "/home/${username}/nixcfg";
    flake = "--flake ${flakedir}";
    logToNom = "--log-format internal-json |& nom --json";

    script = name: text:
      pkgs.writeShellApplication {
        runtimeInputs = [pkgs.nix-output-monitor];
        inherit name text;
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
      (script "tnix" "sudo -v && sudo nixos-rebuild test ${flake} ${logToNom}")
      (script "dbnix" "sudo -v && sudo nixos-rebuild dry-build ${flake} ${logToNom}")
      (script "danix" "sudo -v && sudo nixos-rebuild dry-activate ${flake} ${logToNom}")
      (script "bnix" ''
        sudo -v
        sudo nixos-rebuild boot ${flake} ${logToNom}

        ${gitTagScript}
      '')
      (script "snix" ''
        sudo -v
        sudo nixos-rebuild switch ${flake} ${logToNom}

        ${gitTagScript}
      '')
    ];
  };
}
