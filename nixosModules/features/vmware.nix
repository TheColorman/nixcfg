{ lib, config, pkgs, ... }: let
  cfg = config.myNixOS.vmware;
in {
  options.myNixOS.vmware.enable = lib.mkEnableOption "enable vmware services";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ vmware-workstation ];
    virtualisation.vmware.host.enable = true;
  };
}
