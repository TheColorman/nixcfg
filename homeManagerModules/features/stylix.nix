{ lib, config, ... }:
let
  cfg = config.myHomeManager.stylix;
in
{
  imports = [ ];

  options.myHomeManager.stylix.enable = lib.mkEnableOption "Enable Stylix";

  config = lib.mkIf cfg.enable {
    stylix.autoEnable = true;
    stylix.enable = true;
  };
}
