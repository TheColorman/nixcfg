{ lib, pkgs, ... }: let 
  inherit (pkgs) alsa-utils wlrctl xorg;
in {
  nixpkgs.overlays = [ (final: prev: {
    safeeyes = prev.safeeyes.overrideAttrs (old: {
      preFixup = ''
        makeWrapperArgs+=(
          "''${gappsWrapperArgs[@]}"
          --prefix PATH : ${lib.makeBinPath [ alsa-utils wlrctl xorg.xprop ]}
        )
      '';
    });
  }) ];
  environment.systemPackages = [ pkgs.safeeyes ];
}
