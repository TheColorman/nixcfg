{ inputs, ... }:
{
  flake.nixosModules.apps-nix-index =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Scan the compressed database once per build, not on every shell typo.
      # A sorted executable-only index lets look binary-search exact names.
      commandIndex =
        pkgs.runCommand "nixpkgs-command-index"
          {
            nativeBuildInputs = [
              config.programs.nix-index.package
              pkgs.gawk
            ];
          }
          ''
            set -o pipefail
            export LC_ALL=C
            nix-locate --color never --no-group --type x --type s \
              --whole-name --at-root --regex '/bin/[^/]+$' \
              | awk '{ name = $0; sub(/^.*\/bin\//, "", name); print name "\t" $1 }' \
              | sort -u > "$out"
          '';

      commandNotFound = pkgs.writeShellScript "command-not-found" ''
        cmd=$1
        printf '%s: command not found\n' "$cmd" >&2

        # Keep pipelines and Midnight Commander free of package hints.
        if [[ -z "''${MC_SID-}" && -t 1 ]]; then
          # Include the tab so short names cannot match longer executables.
          matches=$(LC_ALL=C ${lib.getExe' pkgs.util-linux "look"} -- "$cmd"$'\t' ${commandIndex})
          if [[ -n "$matches" ]]; then
            printf 'Found in nixpkgs:\n' >&2
            while IFS=$'\t' read -r _ attr; do
              printf '  nixpkgs#%s\n' "''${attr%.out}" >&2
            done <<< "$matches"
          fi
        fi

        exit 127
      '';
    in
    {
      imports = [ inputs.nix-index-database.nixosModules.nix-index ];

      programs.nix-index = {
        enableBashIntegration = false;
        enableZshIntegration = false;
        enableFishIntegration = false;
      };

      programs.bash.interactiveShellInit = ''
        command_not_found_handle() {
          ${commandNotFound} "$@"
        }
      '';

      programs.zsh.interactiveShellInit = ''
        command_not_found_handler() {
          ${commandNotFound} "$@"
        }
      '';

      programs.fish.interactiveShellInit = ''
        function fish_command_not_found
          ${commandNotFound} $argv
        end
      '';
    };
}
