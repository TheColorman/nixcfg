{ lib, config, ... }:
let
  cfg = config.myNixOS.input-remapper;
in
{
  imports = [ ];

  options.myNixOS.input-remapper.enable = lib.mkEnableOption "Enable input remapper";

  config = lib.mkIf cfg.enable {
    services.input-remapper.enable = true;
  };
}
