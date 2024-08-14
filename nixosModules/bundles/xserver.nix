{ lib, config, ... }:
let
  cfg = config.myNixOS.xserver;
in
{
  imports = [ ];

  options.myNixOS.xserver.enable = lib.mkEnableOption "Enable X11 server";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "colemak_dh";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # 32-bit application support
    hardware.graphics.enable32Bit = true;
  };
}
