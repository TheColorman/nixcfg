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
    in
    {
      environment = {
        systemPackages = [
          inputs.ki-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        variables.EDITOR = lib.mkForce "ki";
      };

      home-manager.users."${username}".xdg.configFile."ki/config.json".text = builtins.toJSON {
        keyboard_layout = "COLEMAK-DH (ANSI)";
        languages = { };
        # TODO: generate Stylix theme, see https://ki-editor.org/docs/themes
        theme = "Tokyo Night";
        wakatime = {
          enabled = true;
          cli_path = lib.getExe pkgs.wakatime-cli;
        };
      };
    };
}
