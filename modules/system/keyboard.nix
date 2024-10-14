# The override used here is inspired by the one built into NixOS at
# https://github.com/NixOS/nixpkgs/blob/5633bcff0c616/nixos/modules/services/x11/extra-layouts.nix#L81
{ pkgs
, config
, lib
, ...
}:
let
  BBKT = pkgs.fetchFromGitHub {
    owner = "DreymaR";
    repo = "BigBagKbdTrixXKB";
    rev = "46f0ac12d0e6cf8de16c24c69d7e7046080c8605";
    sha256 = "sha256-WN4nLF5WIMvGgw1FPO9KxsEKcVUq0SiA4e1plu2D7O4=";
  };
  BBKT_XKB = "${BBKT}/xkb-data_xmod/xkb";

  xkb_patched = pkgs.xorg.xkeyboardconfig.overrideAttrs (oldAttrs: {
    postInstall = lib.strings.concatStrings [
      oldAttrs.postInstall
      ''
        # Overwrite xkb data with DreymaR's Big Bag
        cp ${BBKT_XKB}/geometry/* $out/etc/X11/xkb/geometry/
        cp ${BBKT_XKB}/keycodes/* $out/etc/X11/xkb/keycodes/
        cp ${BBKT_XKB}/rules/* $out/etc/X11/xkb/rules/
        cp ${BBKT_XKB}/symbols/* $out/etc/X11/xkb/symbols/
        cp ${BBKT_XKB}/types/* $out/etc/X11/xkb/types/
      ''
    ];
  });
in
{
  environment.sessionVariables = {
    # runtime override supported by multiple libraries e. g. libxkbcommon
    # https://xkbcommon.org/doc/current/group__include-path.html
    XKB_CONFIG_ROOT = config.services.xserver.xkb.dir;
  };

  services.xserver = {
    xkb.dir = "${xkb_patched}/etc/X11/xkb";
    exportConfiguration =
      config.services.xserver.displayManager.startx.enable
      || config.services.xserver.displayManager.sx.enable;
  };
}
