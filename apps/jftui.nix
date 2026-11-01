{
  flake.nixosModules.apps-jftui =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.my) username;
      hmUser = config.home-manager.users."${username}";
      mpvProgram = hmUser.programs.mpv;
      mpv = mpvProgram.finalPackage;
      mpvScriptFiles = lib.concatMap (
        script:
        [ "${script}/share/mpv/scripts/${script.scriptName}" ]
        ++ map (name: "${script}/share/mpv/scripts/${name}") (script.extraScriptsToLoad or [ ])
      ) mpvProgram.scripts;
      mpvScriptConfig = lib.concatMapStringsSep "\n" (path: "script=${path}") mpvScriptFiles;
      renderScriptOpts =
        options:
        lib.generators.toKeyValue {
          mkKeyValue = lib.generators.mkKeyValueDefault {
            mkValueString =
              value: if builtins.isBool value then (if value then "yes" else "no") else toString value;
          } "=";
          listsAsDuplicateKeys = true;
        } options;
      jftuiScriptOpts = lib.mapAttrs' (
        name: options:
        lib.nameValuePair "jftui/script-opts/${name}.conf" {
          text = renderScriptOpts options;
        }
      ) mpvProgram.scriptOpts;
      jftui = pkgs.jftui.override { inherit mpv; };
      jftuiWithMpvTools =
        pkgs.runCommand "jftui-with-mpv-tools"
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          }
          ''
            mkdir -p $out/bin
            makeWrapper ${jftui}/bin/jftui $out/bin/jftui ${lib.escapeShellArgs mpvProgram.extraMakeWrapperArgs}
          '';
    in
    {
      users.users."${username}".packages = [
        jftuiWithMpvTools
      ];

      home-manager.users."${username}".xdg.configFile = jftuiScriptOpts // {
        # jftui uses its own config directory; include the regular mpv config
        # and load the same script packages configured in programs.mpv.scripts.
        "jftui/mpv.conf".text = ''
          include=${hmUser.xdg.configHome}/mpv/mpv.conf
          ${mpvScriptConfig}
        '';
      };
    };
}
