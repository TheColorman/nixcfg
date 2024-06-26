{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
  ];

  users.mutableUsers = false;
  system.nixos.label = "update_kitty_config";
}
