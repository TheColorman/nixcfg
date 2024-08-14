{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.tailscale;
in
{
  imports = [ ];

  options.myNixOS.tailscale.enable = lib.mkEnableOption "Enable Tailscale";

  config = lib.mkIf cfg.enable {
    myNixOS.sops.enable = true;

    services.tailscale = {
      enable = true;
      authKeyFile = "${config.sops.secrets.tailscale_auth.path}";
      extraUpFlags = [
        "--accept-routes"
        # "--exit-node=100.74.238.25"
        "--reset"
      ];
      useRoutingFeatures = "client";
    };
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
