{
  pkgs,
  config,
  ...
}: let
  inherit (config.my) username;

  version = "1.14.9b";
  zen-browser = pkgs.appimageTools.wrapType2 {
    pname = "zen-browser";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
      hash = "sha256-uwnOKkLlQVWoo8mdjFSt5dNgL6rPQPO2zuGqB3EHrtI=";
    };
  };
in {
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit zen-browser;
    })
  ];

  home-manager.users."${username}".home.packages = [
    pkgs.zen-browser
  ];

  my.browser = pkgs.zen-browser;
}
