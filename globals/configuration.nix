{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
  ];

  users.mutableUsers = false;
  system.nixos.label = "update_container_plus_wallpaper";
}
