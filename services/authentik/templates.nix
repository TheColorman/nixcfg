{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.authentik_templates = pkgs.runCommandLocal "authentik-templates" { } ''
      mkdir -p $out/custom-templates

      cp -rL \
        ${./_templates}/. \
        $out/custom-templates/
    '';
  };
}
