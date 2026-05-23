{
  flake.nixosModules.apps-libreoffice =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [ carlito ];
      environment.systemPackages = with pkgs; [ libreoffice ];
    };
}
