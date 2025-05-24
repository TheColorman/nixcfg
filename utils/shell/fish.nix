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
    users.users."${username}".shell = fish;

    home-manager.users."${username}" = {
      home.shell.enableFishIntegration = true;
      programs.fish = {
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
        preferAbbrs = true;
        shellAbbrs = {
          ls = lib.getExe pkgs.eza;
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
