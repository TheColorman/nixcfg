{ inputs, ... }:
{
  flake.nixosModules.apps-ki =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config.my) username;
      cfg = config.home-manager.users."${username}".programs.ki;
    in
    {
      # Set up marker option so other modules know that Ki Editor is enabled
      options.my.markers.ki.enable = lib.mkEnableOption "Ki editor";

      config = {
        # Set marker
        my.markers.ki.enable = true;

        # Make globally available
        environment = {
          systemPackages = [
            inputs.ki-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          variables.EDITOR = lib.mkForce "ki";
        };

        home-manager.users."${username}" = {
          # Create home-manager option
          options.programs.ki.settings = lib.mkOption {
            type = lib.types.submodule { freeformType = (pkgs.formats.json { }).type; };
            default = { };
          };

          config = {
            # Set home manager options
            programs.ki.settings = {
              keyboard_layout = "COLEMAK-DH (ANSI)";
              languages = { };
              theme = "Tokyo Night";
              wakatime = {
                enabled = true;
                cli_path = lib.getExe pkgs.wakatime-cli;
              };
            };

            # Write options to config file
            xdg.configFile."ki/config.json".text = builtins.toJSON cfg.settings;
          };
        };
      };

    };
}
