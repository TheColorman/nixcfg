{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.gpg;
in
{
  imports = [ ];

  options.myNixOS.gpg.enable = lib.mkEnableOption "Enable GPG";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gnupg ];
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };
}
