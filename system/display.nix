{
  flake.nixosModules.system-display = {
    services.xserver.videoDrivers = ["displaylink" "modesetting" "fbdev"];
  };
}
