{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib) types;
  inherit (config.my) username;
  inherit (pkgs) fish;
  cfg = config.my.fish;
in {
  imports = [
    ./default.nix
    ./starship.nix
  ];

  options.my.fish.preInit = mkOption {
    type = types.lines;
    default = "";
    description = ''
      Shell script code called before any plugins are initialised
    '';
  };

  config = {
    my.fish.preInit = ''
      # Refresh async shell when PWD changes
      set -g -a async_prompt_on_variable PWD
    '';

    programs.fish.enable = true;
    users.users = {
      "${username}".shell = fish;
      # Root can have a little fish
      root.shell = fish;
    };

    home-manager.users."${username}" = {
      home.shell.enableFishIntegration = true;
      programs.fish = let
        inherit (lib.meta) getExe;
        inherit (pkgs) eza xxd;
      in {
        enable = true;
        functions = {
          pythonEnv = ''
            function pythonEnv --description 'start a nix-shell with the given python packages' --argument pythonVersion
              if set -q argv[2]
                set argv $argv[2..-1]
              end

              for el in $argv
                set ppkgs $ppkgs "python"$pythonVersion"Packages.$el"
              end

              nix-shell -p $ppkgs
            end
          '';
          randstr = ''
            function randstr --description 'Generate a random alphanumeric string'
                set -l default_length 16
                set -l output_length $default_length
                if test (count $argv) -ge 1
                    if string match -q --regex '^[1-9][0-9]*$' -- $argv[1]
                        set output_length $argv[1]
                    else
                        echo "Warning: Invalid length specified. Using default length of $default_length." >&2
                    end
                end

                set -l bytes_to_read (math "ceil($output_length / 2)")
                set -l hex_output (${getExe xxd} -p -l $bytes_to_read /dev/urandom | head -c $output_length)
                echo (string trim --right $hex_output)
            end
          '';
        };
        interactiveShellInit = ''
          set -U fish_greeting
        '';
        shellInitLast = ''
          # disable transient prompt on C-c
          # instead use custom function that just clears the command line
          function __transient_ctrl_c_execute
            commandline ""
          end
        '';
        shellAliases = {
          ls = getExe eza;
        };
        plugins = [
          {
            name = "fish-async-prompt";
            src = pkgs.fetchFromGitHub {
              owner = "infused-kim";
              repo = "fish-async-prompt";
              rev = "07e107635e693734652b0709dd34166820f1e6ff";
              hash = "sha256-rE80IuJEqnqCIE93IzeT2Nder9j4fnhFEKx58HJUTPk=";
            };
          }
          {
            name = "transient";
            src = pkgs.fetchFromGitHub {
              owner = "zzhaolei";
              repo = "transient.fish";
              rev = "7091a1ef574e4c2d16779e59d37ceb567128c787";
              hash = "sha256-rZqMQiVGEEYus5MxkpFhaXnjVStmsjWkGly4B6bjcks=";
            };
          }
          {
            name = "git";
            inherit (pkgs.fishPlugins.plugin-git) src;
          }
          {
            name = "000-preinit";
            src = pkgs.writeTextDir "conf.d/000-preinit.fish" cfg.preInit;
          }
        ];
      };
    };
  };
}
