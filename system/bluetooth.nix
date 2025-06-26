{config, ...}: let
  # hyprland does not have a bluetooth manager built in
  missingBTManager = config.programs.hyprland.enable;
in {
  hardware.bluetooth.enable = true;
  services.blueman.enable = missingBTManager;
}
