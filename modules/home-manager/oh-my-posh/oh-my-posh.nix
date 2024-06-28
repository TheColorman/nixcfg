{ pkgs, ... }: let
  default_config = with pkgs; lib.importJSON ./default_config.json;
in  {
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  enableFishIntegration = false;
  enableNushellIntegration = false;
  settings = default_config;
}
