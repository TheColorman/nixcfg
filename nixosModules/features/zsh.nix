{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.zsh;
in
{
  imports = [ ];

  # This config also requires the home-manager zsh config to be enabled
  options.myNixOS.zsh.enable = lib.mkEnableOption "Enable system zsh config";

  config = lib.mkIf cfg.enable {
    home-manager.users.color.myHomeManager.zsh.enable = true;
    users.users.${config.myNixOS.username}.shell = pkgs.zsh;
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      zsh
      zoxide
      highlight
    ];
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
