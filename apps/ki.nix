{ inputs, ... }:
{
  flake.nixosModules.apps-ki =
    { pkgs, config, ... }:
    let
      inherit (config.my) username;
    in
    {
      environment.systemPackages = [
        inputs.ki-editor.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      home-manager.users."${username}".xdg.configFile."ki/config.json".text = builtins.toJSON {
        keyboard_layout = "COLEMAK-DH (ANSI)";
        languages = { };
      };
    };
}
