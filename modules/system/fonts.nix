{ pkgs, ... }:
let
  nerdfont = with pkgs; (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
in
{
  environment.systemPackages = with pkgs; [ nerdfont ];
  fonts.packages = with pkgs; [ nerdfont ];
}
