{
  flake.nixosModules.utils-stylix-ki =
    { config, lib, ... }:
    let
      inherit (config.my) username;

      kiEnabled = config.my.markers ? ki && config.my.markers.ki.enable;
    in
    {
      config = lib.mkIf kiEnabled {
        home-manager.users."${username}" = {
          xdg.configFile."ki/themes/stylix.json".source =
            # By default it generates a theme with
            # `"appearance" = "unspecified"` which crashes Ki. I override the
            # theme to change that key to the Stylix polarity. The `colors`
            # function is defined here:
            # - https://github.com/SenchoPens/base16.nix/blob/75ed5e5e3fce37df22e49125181fa37899c3ccd6/lib/mk-theme.nix#L7
            (config.lib.stylix.colors {
              templateRepo = config.stylix.inputs.tinted-zed;
              target = "base16";
            }).overrideAttrs
              {
                phases = [
                  "buildPhase"
                  "fixupPhase"
                  "installPhase"
                ];

                fixupPhase = ''
                  substituteInPlace theme \
                    --replace-fail "unspecified" "${config.stylix.polarity}"
                '';
              };

          programs.ki.settings.theme = lib.mkForce "Base16 Stylix";
        };
      };
    };
}
