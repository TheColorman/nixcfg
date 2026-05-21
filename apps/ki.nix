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
        # TODO: re-enable when I figure out how to enable WakaTime in Ki
        # variables.EDITOR = lib.mkForce "ki";
      };

      home-manager.users."${username}".xdg.configFile."ki/config.json".text = builtins.toJSON {
        keyboard_layout = "COLEMAK-DH (ANSI)";
        languages = { };
      };
    };
}
