{...}: {
  environment.systemPackages = with pkgs; [
    wget
  ];

  users.mutableUsers = false;
  system.nixos.label = "hyprland";
}