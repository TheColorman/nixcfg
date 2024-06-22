{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
  ];

  users.mutableUsers = false;
  system.nixos.label = "add_gaming_stuff";
}
