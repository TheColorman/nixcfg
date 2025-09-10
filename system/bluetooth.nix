{config, ...}: let
  # hyprland does not have a bluetooth manager built in
  missingBTManager = config.programs.hyprland.enable;
in {
  hardware.bluetooth = {
    enable = true;
    # Required for DualShock 4 BT.
    # See https://wiki.gentoo.org/wiki/Sony_DualShock
    input.General.UserspaceHID = true;
  };

  services.blueman.enable = missingBTManager;
}
