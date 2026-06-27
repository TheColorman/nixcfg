{
  flake.nixosModules.services-safeeyes =
    { lib, pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_final: prev: {
          safeeyes = prev.safeeyes.overrideAttrs (_old: {
            preFixup = ''
              makeWrapperArgs+=(
                "''${gappsWrapperArgs[@]}"
                --prefix PATH : ${
                  lib.makeBinPath (
                    with pkgs;
                    [
                      alsa-utils
                      wlrctl
                      xprop
                    ]
                  )
                }
              )
            '';
          });
        })
      ];
      environment.systemPackages = [ pkgs.safeeyes ];

      # Enable autostart
      my.autostart = [ "${pkgs.writeScript "launch-safeyes" "sleep 5; ${lib.getExe pkgs.safeeyes}"}" ];
    };
}
