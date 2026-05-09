{
  flake.nixosModules.apps-lutris =
    { config, ... }:
    let
      inherit (config.my) username;
    in
    {
      # TODO: Temporary "fix" for failing OpenLDAP test on i686. This is likely
      # a bug in the 32-bit version of OpenLDAP, so this is probably dangerous.
      # See https://github.com/NixOS/nixpkgs/issues/514113
      nixpkgs.overlays = [
        (_: prev: {
          openldap = prev.openldap.overrideAttrs {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          };
        })
      ];

      home-manager.users."${username}".programs.lutris.enable = true;
    };
}
