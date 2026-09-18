{
  flake.nixosModules.apps-opencode =
    { config, pkgs, ... }:
    {
      # Patched version of opencode, see
      # https://github.com/NixOS/nixpkgs/issues/563241#issuecomment-5667670049
      # https://github.com/NixOS/nixpkgs/pull/564101
      users.users."${config.my.username}".packages = [
        (pkgs.opencode.overrideAttrs (
          final: prev: {
            postPatch = prev.postPatch + ''
              # fix for bun 1.4.x
              substituteInPlace packages/opencode/script/build.ts \
                --replace-fail 'splitting: true,' 'splitting: false,'
            '';
          }
        ))
      ];
    };
}
